// ============================================================================
// hypr-cursor —— 光标模式常驻守护（C++）
//
// 为什么不用 Hyprland 的 bind + shell 脚本：
//   * 每次按键都要 spawn 一个 sh 进程，多键并发时开销大且时序不可靠
//   * submap 内的 release 绑定在实测中会丢失，导致方向标记残留、光标卡住
//
// 本程序的做法：
//   * 直接读 /dev/input/event*（evdev），自己维护按键按下状态（press/release 精确）
//   * 每 16ms 读一次真实光标位置（cursorpos），按方向向量计算后
//     用 dispatch movecursor 设置**绝对位置**（不是相对 mousemove，无累积误差）
//   * 点击 / 滚轮通过 uinput 虚拟鼠标发送
//   * 通过 Hyprland 事件 socket 的 submap 事件判断是否处于光标模式
//
// 需要 root（读 /dev/input、写 /dev/uinput）。
// ============================================================================
#include <linux/input.h>
#include <linux/uinput.h>

#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/uio.h>

#include <dirent.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <unistd.h>

#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <deque>
#include <string>
#include <vector>

namespace {

constexpr const char* kRuntime = "/run/user/1000";
constexpr const char* kHyprDir = "/run/user/1000/hypr";
// 光标模式标志：由 cursor-enter.sh 创建、cursor-exit.sh 删除。
// 不用 Hyprland 事件 socket 的 submap 事件 —— 实测连接会在每次 submap
// 变化后被关闭，重连时状态丢失，导致按键无响应。
constexpr const char* kActiveFile = "/run/user/1000/hypr-cursor-active";
constexpr int kTickMs = 16;
constexpr double kFastPx = 18.0;   // 每帧像素（≈1125 px/s）
constexpr double kSlowPx = 3.0;    // 每帧像素（≈187 px/s）

bool g_run = true;
bool cursor_active() { return access(kActiveFile, F_OK) == 0; }
void on_signal(int) { g_run = false; }

double now_ms() {
    timespec ts{};
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1e6;
}

// ---------------------------------------------------------------- Hyprland IPC
class Hypr {
public:
    bool connect_once() {
        close_all();
        std::string dir = find_instance();
        if (dir.empty()) return false;

        cmd_fd_ = connect_socket(dir + "/.socket.sock");
        evt_fd_ = connect_socket(dir + "/.socket2.sock");
        if (cmd_fd_ < 0 || evt_fd_ < 0) { close_all(); return false; }
        fcntl(evt_fd_, F_SETFL, O_NONBLOCK);

        // 注意：不要在这里发 "submap" 命令 —— 该 IPC 命令不存在，
        // Hyprland 会直接关闭连接，导致 ok() 变 false → 无限重连。
        fprintf(stderr, "[hypr-cursor] connected (%s)\n", dir.c_str());
        return true;
    }

    bool ok() const { return cmd_fd_ >= 0 && evt_fd_ >= 0; }
    bool in_cursor() const { return in_cursor_; }
    int evt_fd() const { return evt_fd_; }

    std::string command(const std::string& cmd) {
        if (cmd_fd_ < 0) return "";
        std::string line = cmd + "\n";
        if (write(cmd_fd_, line.data(), line.size()) < 0) {
            close_all();                    // 连接已断（Hyprland 重启等），交给主循环重连
            return "";
        }
        char buf[512];
        ssize_t n = read(cmd_fd_, buf, sizeof(buf) - 1);
        if (n <= 0) {
            // 超时（EAGAIN）只说明这次没及时回复，不能当作断线
            if (n == 0 || (errno != EAGAIN && errno != EWOULDBLOCK)) close_all();
            return "";
        }
        return std::string(buf, n);
    }

    // 读取事件 socket 中可用的所有行；返回 submap 是否发生变化
    void drain_events() {
        if (evt_fd_ < 0) return;
        char buf[4096];
        for (;;) {
            ssize_t n = read(evt_fd_, buf, sizeof(buf));
            if (n == 0) {                  // EOF：Hyprland 侧关闭，标记断线
                close(evt_fd_);
                evt_fd_ = -1;
                evt_buf_.clear();
                return;
            }
            if (n < 0) break;
            evt_buf_.append(buf, n);
        }
        size_t pos;
        while ((pos = evt_buf_.find('\n')) != std::string::npos) {
            std::string line = evt_buf_.substr(0, pos);
            evt_buf_.erase(0, pos + 1);
            handle_event(line);
        }
        if (evt_buf_.size() > 1 << 20) evt_buf_.clear();
    }

    bool cursor_pos(int& x, int& y) {
        // 这个版本的 Hyprland 没有 "cursorpos" IPC 命令（返回 unknown request），
        // 也没有 hl.cursorpos()；位置要用 repl 执行 Lua：hl.get_cursor_pos()
        std::string r = command(
            "repl local p=hl.get_cursor_pos() return math.floor(p.x)..\",\"..math.floor(p.y)");
        if (r.empty()) return false;
        int a = 0, b = 0;
        if (sscanf(r.c_str(), "%d,%d", &a, &b) != 2) return false;
        x = a; y = b;
        return true;
    }

    void move_cursor(int x, int y) {
        // 注意：这个 Hyprland 版本的 dispatch 走 Lua 表达式，
        // 不能写 "dispatch movecursor x y"，必须用 hl.dsp.cursor.move({...})
        char c[160];
        snprintf(c, sizeof(c), "dispatch hl.dsp.cursor.move({ x = %d, y = %d })", x, y);
        command(c);
    }

private:
    static std::string find_instance() {
        DIR* d = opendir(kHyprDir);
        if (!d) return "";
        std::string best;
        time_t best_t = 0;
        while (dirent* e = readdir(d)) {
            if (e->d_name[0] == '.') continue;
            std::string p = std::string(kHyprDir) + "/" + e->d_name + "/.socket.sock";
            struct stat st{};
            if (stat(p.c_str(), &st) != 0 || !S_ISSOCK(st.st_mode)) continue;
            if (st.st_mtime >= best_t) { best_t = st.st_mtime; best = std::string(kHyprDir) + "/" + e->d_name; }
        }
        closedir(d);
        return best;
    }

    static int connect_socket(const std::string& path) {
        int fd = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
        if (fd < 0) return -1;
        sockaddr_un addr{};
        addr.sun_family = AF_UNIX;
        if (path.size() >= sizeof(addr.sun_path)) { close(fd); return -1; }
        strncpy(addr.sun_path, path.c_str(), sizeof(addr.sun_path) - 1);
        if (connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) { close(fd); return -1; }
        // 防止 Hyprland 无响应时把守护进程卡死
        timeval tv{};
        tv.tv_sec = 1;
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));
        return fd;
    }

    void close_all() {
        if (cmd_fd_ >= 0) close(cmd_fd_);
        if (evt_fd_ >= 0) close(evt_fd_);
        cmd_fd_ = evt_fd_ = -1;
        evt_buf_.clear();
    }

    void handle_event(const std::string& line) {
        // 事件格式: submap>>cursor
        const std::string tag = "submap>>";
        if (line.rfind(tag, 0) != 0) return;
        std::string name = line.substr(tag.size());
        bool was = in_cursor_;
        in_cursor_ = (name == "cursor");
        if (was != in_cursor_) fprintf(stderr, "[hypr-cursor] submap=%s\n", name.c_str());
    }

    int cmd_fd_ = -1;
    int evt_fd_ = -1;
    bool in_cursor_ = false;
    std::string evt_buf_;
};

// ---------------------------------------------------------------- uinput 鼠标
class VMouse {
public:
    bool create() {
        fd_ = open("/dev/uinput", O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        if (fd_ < 0) return false;
        ioctl(fd_, UI_SET_EVBIT, EV_KEY);
        ioctl(fd_, UI_SET_KEYBIT, BTN_LEFT);
        ioctl(fd_, UI_SET_KEYBIT, BTN_RIGHT);
        ioctl(fd_, UI_SET_KEYBIT, BTN_MIDDLE);
        ioctl(fd_, UI_SET_EVBIT, EV_REL);
        ioctl(fd_, UI_SET_RELBIT, REL_WHEEL);

        uinput_setup us{};
        us.id.bustype = BUS_USB;
        us.id.vendor = 0x1d00;
        us.id.product = 0x0c05;
        us.id.version = 1;
        snprintf(us.name, sizeof(us.name), "hypr-cursor virtual mouse");
        if (ioctl(fd_, UI_DEV_SETUP, &us) < 0) return false;
        if (ioctl(fd_, UI_DEV_CREATE) < 0) return false;
        return true;
    }

    void click(int btn) {
        emit(EV_KEY, btn, 1);
        emit(EV_SYN, SYN_REPORT, 0);
        emit(EV_KEY, btn, 0);
        emit(EV_SYN, SYN_REPORT, 0);
    }
    void wheel(int delta) {
        emit(EV_REL, REL_WHEEL, delta);
        emit(EV_SYN, SYN_REPORT, 0);
    }
    void button(int btn, bool down) {
        emit(EV_KEY, btn, down ? 1 : 0);
        emit(EV_SYN, SYN_REPORT, 0);
    }

    ~VMouse() {
        if (fd_ >= 0) { ioctl(fd_, UI_DEV_DESTROY); close(fd_); }
    }

private:
    void emit(int type, int code, int value) {
        input_event ev{};
        ev.type = type; ev.code = code; ev.value = value;
        if (write(fd_, &ev, sizeof(ev)) < 0) { /* ignore */ }
    }
    int fd_ = -1;
};

// ---------------------------------------------------------------- 键盘
struct Keyboard {
    int fd = -1;
    std::string path;
};

// 判断是否是"主键盘"接口：要求具备字母键与空格（排除多媒体/系统控制接口，
// 它们也会带 kbd handler，但只暴露音量/电源等少量键）。
bool is_keyboard(int fd) {
    unsigned long bits[KEY_CNT / (8 * sizeof(unsigned long)) + 1] = {0};
    if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(bits)), bits) < 0) return false;
    auto has = [&](int code) {
        return (bits[code / (8 * sizeof(unsigned long))] >> (code % (8 * sizeof(unsigned long)))) & 1UL;
    };
    // 任意布局的实体键盘都会有这些物理键
    return has(KEY_A) && has(KEY_W) && has(KEY_S) && has(KEY_D) && has(KEY_SPACE) && has(KEY_ENTER);
}

// 增量扫描 /dev/input，把新出现的键盘加入 out（支持热插拔）
void scan_keyboards(std::vector<Keyboard>& out) {
    DIR* d = opendir("/dev/input");
    if (!d) return;
    while (dirent* e = readdir(d)) {
        if (strncmp(e->d_name, "event", 5) != 0) continue;
        std::string p = std::string("/dev/input/") + e->d_name;
        bool known = false;
        for (auto& k : out) if (k.path == p) { known = true; break; }
        if (known) continue;

        int fd = open(p.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        if (fd < 0) continue;
        char name[256] = {0};
        ioctl(fd, EVIOCGNAME(sizeof(name) - 1), name);
        // 排除虚拟设备：dotool 注入的按键不能被当成物理输入（否则会重复响应）
        if (strstr(name, "dotool") || strstr(name, "hypr-cursor") || !is_keyboard(fd)) {
            close(fd);
            continue;
        }
        fprintf(stderr, "[hypr-cursor] + keyboard: %s (%s)\n", name, e->d_name);
        out.push_back({fd, p});
    }
    closedir(d);
}

// ---------------------------------------------------------------- 状态
struct State {
    bool up = false, down = false, left = false, right = false;
    bool slow = false;
    bool drag = false;
    double wheel_acc = 0.0;
};

// 光标位置由 cursor-enter.sh 写入（"x y"）。
// 不用 repl 查询 hl.get_cursor_pos()：实测 repl 会偶发超时（阻塞 1s），
// 放在移动路径上会导致卡顿。
constexpr const char* kPosFile = "/run/user/1000/hypr-cursor-pos";

bool read_pos_file(int& x, int& y) {
    FILE* f = fopen(kPosFile, "r");
    if (!f) return false;
    int a = 0, b = 0;
    int n = fscanf(f, "%d %d", &a, &b);
    fclose(f);
    if (n != 2) return false;
    x = a; y = b;
    return true;
}

}  // namespace

int main() {
    signal(SIGTERM, on_signal);
    signal(SIGINT, on_signal);
    signal(SIGPIPE, SIG_IGN);   // Hyprland 重启时写 socket 不能把进程杀掉

    Hypr hypr;
    if (!hypr.connect_once()) {
        fprintf(stderr, "[hypr-cursor] cannot connect Hyprland IPC\n");
        return 1;
    }

    std::vector<Keyboard> kbs;
    scan_keyboards(kbs);
    if (kbs.empty()) fprintf(stderr, "[hypr-cursor] 暂无键盘，等待热插拔\n");

    VMouse vm;
    if (!vm.create()) {
        fprintf(stderr, "[hypr-cursor] cannot create uinput mouse\n");
        return 1;
    }

    State st;
    bool was_cursor = false;
    double next_tick = now_ms() + kTickMs;
    // 本地跟踪的光标位置：每帧累加后 dispatch 设置绝对值。
    // 初始值来自 cursor-enter.sh 写的文件；之后若文件被更新（重新居中 / 网格选点）就重新同步。
    int px = 0, py = 0;
    bool pos_valid = false;
    time_t pos_mtime = 0;

    while (g_run) {
        // 构建 poll 集合：键盘 + Hyprland 事件 socket
        std::vector<pollfd> pfds;
        for (auto& k : kbs) pfds.push_back({k.fd, POLLIN, 0});
        pfds.push_back({hypr.evt_fd(), POLLIN, 0});

        int timeout = static_cast<int>(std::ceil(next_tick - now_ms()));
        if (timeout < 0) timeout = 0;
        if (timeout > kTickMs) timeout = kTickMs;

        int rc = poll(pfds.data(), pfds.size(), timeout);

        // IPC 断开（Hyprland 重启）→ 重连（带节流，避免忙等/刷屏）
        if (!hypr.ok()) {
            static double next_try = 0;
            double tn = now_ms();
            if (tn < next_try) { usleep(50 * 1000); continue; }
            next_try = tn + 500;
            if (!hypr.connect_once()) { usleep(500 * 1000); continue; }
            continue;
        }

        if (rc > 0) {
            // 键盘事件
            for (size_t i = 0; i < kbs.size(); ++i) {
                if (pfds[i].revents & (POLLERR | POLLHUP | POLLNVAL)) {
                    fprintf(stderr, "[hypr-cursor] - keyboard gone: %s\n", kbs[i].path.c_str());
                    close(kbs[i].fd);
                    kbs.erase(kbs.begin() + i);
                    --i;
                    continue;
                }
                if (!(pfds[i].revents & POLLIN)) continue;
                input_event ev{};
                while (read(kbs[i].fd, &ev, sizeof(ev)) == sizeof(ev)) {
                    if (ev.type != EV_KEY) continue;
                    bool down = ev.value != 0;
                    switch (ev.code) {
                        case KEY_W: st.up = down; break;
                        case KEY_S: st.down = down; break;
                        case KEY_A: st.left = down; break;
                        case KEY_D: st.right = down; break;
                        case KEY_I: st.slow = down; break;
                        case KEY_J: if (down && cursor_active()) vm.click(BTN_LEFT); break;
                        case KEY_O: if (down && cursor_active()) vm.click(BTN_RIGHT); break;
                        case KEY_SPACE: if (down && cursor_active()) vm.click(BTN_MIDDLE); break;
                        case KEY_V:
                            if (cursor_active()) { st.drag = down; vm.button(BTN_LEFT, down); }
                            break;
                        case KEY_Q: if (down) st.wheel_acc = -1; else if (st.wheel_acc < 0) st.wheel_acc = 0; break;
                        case KEY_E: if (down) st.wheel_acc = 1; else if (st.wheel_acc > 0) st.wheel_acc = 0; break;
                        default: break;
                    }
                }
            }
            // Hyprland 事件
            if (pfds.back().revents & (POLLIN | POLLHUP)) hypr.drain_events();
        }

        // 模式切换：离开光标模式时释放按键并清空状态
        bool act = cursor_active();
        if (act != was_cursor) {
            fprintf(stderr, "[hypr-cursor] %s\n", act ? "cursor mode ON" : "cursor mode OFF");
            if (act) {
                struct stat stt{};
                pos_mtime = (stat(kPosFile, &stt) == 0) ? stt.st_mtime : 0;
                pos_valid = read_pos_file(px, py) || hypr.cursor_pos(px, py);
            }
            was_cursor = act;
        }
        if (!act && st.drag) { vm.button(BTN_LEFT, false); }
        if (!act) st = State{};

        double t = now_ms();
        if (t < next_tick) continue;
        next_tick = t + kTickMs;

        // 每秒重扫一次设备，支持键盘热插拔
        static double next_scan = 0;
        if (t >= next_scan) { scan_keyboards(kbs); next_scan = t + 1000; }

        if (!cursor_active()) continue;

        // 位置文件被更新（重新居中 / 网格选点）→ 重新同步
        static double next_poschk = 0;
        if (t >= next_poschk) {
            struct stat stt{};
            if (stat(kPosFile, &stt) == 0 && stt.st_mtime != pos_mtime) {
                pos_mtime = stt.st_mtime;
                if (read_pos_file(px, py)) pos_valid = true;
            }
            next_poschk = t + 200;
        }

        // ---- 移动：累加本地坐标 → 设置绝对位置 ----
        int dx = (st.right ? 1 : 0) - (st.left ? 1 : 0);
        int dy = (st.down ? 1 : 0) - (st.up ? 1 : 0);
        if (dx != 0 || dy != 0) {
            double speed = st.slow ? kSlowPx : kFastPx;
            double vx = dx, vy = dy;
            if (dx != 0 && dy != 0) {  // 斜向归一化，保持合速度一致
                const double inv = 1.0 / std::sqrt(2.0);
                vx *= inv; vy *= inv;
            }
            if (!pos_valid) pos_valid = read_pos_file(px, py) || hypr.cursor_pos(px, py);
            if (pos_valid) {
                px += static_cast<int>(std::lround(vx * speed));
                py += static_cast<int>(std::lround(vy * speed));
                hypr.move_cursor(px, py);
            }
        }

        // ---- 滚轮 ----
        if (st.wheel_acc != 0.0) vm.wheel(static_cast<int>(st.wheel_acc));
    }

    for (auto& k : kbs) close(k.fd);
    return 0;
}

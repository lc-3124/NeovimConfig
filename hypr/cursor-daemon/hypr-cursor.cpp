// ============================================================================
// hypr-cursor —— 光标模式常驻守护（C++）
//
// 设计要点（为什么不是 Hyprland bind + shell）：
//   * 每次按键 spawn 一个 sh 进程，多键并发时不可靠
//   * submap 内的 release 绑定实测会丢失，导致方向残留、光标卡住
//
// 为什么不用 Hyprland IPC 移动光标：
//   * Hyprland 的 IPC 是「请求-应答」，每发一条 dispatch 都要等回复；
//     60fps 下每帧等一次回复会造成明显延迟和掉帧
//   * 该版本也没有 cursorpos 命令，位置只能靠 repl 查，而 repl 会偶发超时
//   因此：移动/点击/滚轮全部走 uinput 虚拟鼠标（和真实鼠标同一条路径），
//   写入即返回，零阻塞。
//
// 模式判定用文件标志（由 cursor-enter.sh / cursor-exit.sh 维护）：
//   $XDG_RUNTIME_DIR/hypr-cursor-active
//
// 需要 root（读 /dev/input、写 /dev/uinput）。
// ============================================================================
#include <linux/input.h>
#include <linux/uinput.h>

#include <sys/ioctl.h>
#include <sys/stat.h>

#include <dirent.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <unistd.h>

#include <cmath>
#include <cstdio>
#include <cstring>
#include <ctime>
#include <string>
#include <vector>

namespace {

constexpr const char* kActiveFile = "/run/user/1000/hypr-cursor-active";
constexpr int kTickMs = 16;
constexpr int kFastPx = 18;   // 每帧像素（≈1125 px/s）
constexpr int kSlowPx = 3;    // 每帧像素（≈187 px/s）

bool g_run = true;
void on_signal(int) { g_run = false; }
bool cursor_active() { return access(kActiveFile, F_OK) == 0; }

double now_ms() {
    timespec ts{};
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1e6;
}

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
        ioctl(fd_, UI_SET_RELBIT, REL_X);
        ioctl(fd_, UI_SET_RELBIT, REL_Y);
        ioctl(fd_, UI_SET_RELBIT, REL_WHEEL);
        // 标记为指针设备：否则可能被 libinput 当成触摸板（会套用触控加速曲线）
        ioctl(fd_, UI_SET_PROPBIT, INPUT_PROP_POINTER);

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

    void move(int dx, int dy) {
        if (dx == 0 && dy == 0) return;
        emit(EV_REL, REL_X, dx);
        emit(EV_REL, REL_Y, dy);
        sync();
    }
    void click(int btn) {
        emit(EV_KEY, btn, 1); sync();
        emit(EV_KEY, btn, 0); sync();
    }
    void button(int btn, bool down) { emit(EV_KEY, btn, down ? 1 : 0); sync(); }
    void wheel(int delta) { emit(EV_REL, REL_WHEEL, delta); sync(); }

    ~VMouse() {
        if (fd_ >= 0) { ioctl(fd_, UI_DEV_DESTROY); close(fd_); }
    }

private:
    void emit(int type, int code, int value) {
        input_event ev{};
        ev.type = type; ev.code = code; ev.value = value;
        if (write(fd_, &ev, sizeof(ev)) < 0) { /* ignore */ }
    }
    void sync() { emit(EV_SYN, SYN_REPORT, 0); }
    int fd_ = -1;
};

// ---------------------------------------------------------------- 键盘
struct Keyboard {
    int fd = -1;
    std::string path;
};

// 主键盘接口：具备字母键、空格、回车（排除只带音量/电源键的辅助接口）
bool is_keyboard(int fd) {
    unsigned long bits[KEY_CNT / (8 * sizeof(unsigned long)) + 1] = {0};
    if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(bits)), bits) < 0) return false;
    auto has = [&](int code) {
        return (bits[code / (8 * sizeof(unsigned long))] >> (code % (8 * sizeof(unsigned long)))) & 1UL;
    };
    return has(KEY_A) && has(KEY_W) && has(KEY_S) && has(KEY_D) && has(KEY_SPACE) && has(KEY_ENTER);
}

// 增量扫描 /dev/input：支持键盘热插拔，排除 dotool/自身虚拟设备
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
    int wheel = 0;
};

}  // namespace

int main() {
    signal(SIGTERM, on_signal);
    signal(SIGINT, on_signal);

    std::vector<Keyboard> kbs;
    scan_keyboards(kbs);
    if (kbs.empty()) fprintf(stderr, "[hypr-cursor] 暂无键盘，等待热插拔\n");

    VMouse vm;
    if (!vm.create()) {
        fprintf(stderr, "[hypr-cursor] cannot create uinput mouse\n");
        return 1;
    }
    fprintf(stderr, "[hypr-cursor] ready (evdev -> uinput, no IPC)\n");

    State st;
    bool was_cursor = false;
    double next_tick = now_ms() + kTickMs;
    double next_scan = 0;

    while (g_run) {
        std::vector<pollfd> pfds;
        pfds.reserve(kbs.size());
        for (auto& k : kbs) pfds.push_back({k.fd, POLLIN, 0});

        double t = now_ms();
        int timeout = static_cast<int>(std::ceil(next_tick - t));
        if (timeout < 0) timeout = 0;
        if (timeout > kTickMs) timeout = kTickMs;

        int rc = poll(pfds.data(), pfds.size(), timeout);

        if (rc > 0) {
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
                        case KEY_Q: st.wheel = down ? -1 : 0; break;
                        case KEY_E: st.wheel = down ? 1 : 0; break;
                        default: break;
                    }
                }
            }
        }

        // 模式切换
        bool act = cursor_active();
        if (act != was_cursor) {
            fprintf(stderr, "[hypr-cursor] %s\n", act ? "cursor mode ON" : "cursor mode OFF");
            was_cursor = act;
            if (!act) {
                if (st.drag) vm.button(BTN_LEFT, false);
                st = State{};
            }
        }

        t = now_ms();
        if (t < next_tick) continue;
        next_tick = t + kTickMs;

        if (t >= next_scan) { scan_keyboards(kbs); next_scan = t + 1000; }
        if (!act) continue;

        // ---- 移动（uinput 相对注入，写入即返回）----
        int dx = (st.right ? 1 : 0) - (st.left ? 1 : 0);
        int dy = (st.down ? 1 : 0) - (st.up ? 1 : 0);
        if (dx != 0 || dy != 0) {
            int s = st.slow ? kSlowPx : kFastPx;
            if (dx != 0 && dy != 0) s = static_cast<int>(std::lround(s / std::sqrt(2.0)));
            if (s < 1) s = 1;
            vm.move(dx * s, dy * s);
        }

        // ---- 滚轮 ----
        if (st.wheel != 0) vm.wheel(st.wheel);
    }

    for (auto& k : kbs) close(k.fd);
    return 0;
}

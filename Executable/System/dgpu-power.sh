#!/bin/bash
# ============================================================================
# dgpu-power.sh v3 —— NVIDIA T600 Laptop GPU 电源开关
#
# 设计原则：
#   - 写操作（on/off/reload/toggle/wayle）必须 root 运行，不做自动提权。
#   - status/users 只读，普通用户也能跑。
#   - 每一步都有超时/重试，失败给出明确原因，不静默。
#   - 不自动杀进程；off 被占用时默认拒绝，--kill 才终止（且保护会话进程）。
#
# 用法:
#   sudo dgpu-power.sh on            开启独显
#   sudo dgpu-power.sh off           关闭独显（被占用则拒绝）
#   sudo dgpu-power.sh off --kill    终止占用进程后再关（保护桌面进程）
#   sudo dgpu-power.sh off --force   不做检查强行移除（有风险，慎用）
#   sudo dgpu-power.sh reload        关闭再开启
#   sudo dgpu-power.sh toggle        按当前状态切换
#      dgpu-power.sh status         查看状态（无需 root）
#      dgpu-power.sh users          查看占用进程（无需 root）
#   sudo dgpu-power.sh wayle         重启 wayle 面板（刷新音频默认输出缓存）
#
# 退出码: 0 成功 / 1 失败（原因见输出）
# ============================================================================
set -u

GPU=0000:01:00.0
DEV=/sys/bus/pci/devices/$GPU
PCI=/sys/bus/pci
DRV=/sys/bus/pci/drivers/nvidia
LOCK=/run/dgpu-power.lock

KILL=0
FORCE=0

log()  { printf '[dgpu] %s\n' "$*"; }
die()  { printf '[dgpu] 错误: %s\n' "$*" >&2; exit 1; }

require_root() { [ "$(id -u)" -eq 0 ] || die "此操作需要 root：sudo $0 $*"; }

is_on()   { [ -e "$DEV" ]; }
driver()  { local d; d=$(readlink "$DEV/driver" 2>/dev/null); printf '%s' "${d##*/}"; }
kmod_ok() { [ -n "$(modinfo -n nvidia 2>/dev/null)" ]; }
smi()     { nvidia-smi --query-gpu=name,power.draw --format=csv,noheader 2>/dev/null; }

# 可靠探测：nvidia-smi 在没设备时会把 "No devices were found" 打到 stdout（退出码也不稳），
# 所以必须同时检查退出码和内容，否则会误判为成功。
probe() {
    local out
    out=$(nvidia-smi --query-gpu=name,power.draw --format=csv,noheader 2>/dev/null) || return 1
    case "$out" in ""|*"No devices"*|*"no devices"*|*"not found"*) return 1 ;; esac
    printf '%s' "$out"
}

holder_pids() { fuser /dev/nvidia* 2>/dev/null | tr ' ' '\n' | grep -E '^[0-9]+$' | sort -u; }
holder_detail() { fuser -v /dev/nvidia* 2>&1 | sed 's/^/  /'; }

# 会话关键进程：绝不自动终止
PROTECTED_RE='^(Hyprland|hyprland|Xwayland|Xorg|gnome-shell|mutter|kwin_wayland|plasmashell|sway|wayfire|labwc|river|niri|systemd|systemd-logind|dbus-daemon|dbus-broker|gdm|sddm|greetd|hypridle|hyprlock|uwsm)$'

protected_holder() {
    local p n
    for p in $(holder_pids); do
        n=$(cat "/proc/$p/comm" 2>/dev/null)
        if printf '%s' "$n" | grep -Eq "$PROTECTED_RE"; then
            printf '%s (PID %s)' "$n" "$p"; return 0
        fi
    done
    return 1
}

# ---------------------------------------------------------------- on
do_on() {
    kmod_ok || die "当前内核 $(uname -r) 下没有 nvidia 模块文件，请先重启或重装 nvidia-open-dkms"

    # 顺序很重要：设备不在总线上时先 rescan，否则 modprobe 会报 "No such device"
    if is_on; then
        log "PCI 设备已存在"
    else
        log "rescan PCI ..."
        echo 1 > "$PCI/rescan" 2>/dev/null || die "写 $PCI/rescan 失败"
        local i
        for i in $(seq 1 20); do is_on && break; sleep 0.5; done
        is_on || die "rescan 后设备未出现"
        log "设备已重新枚举"
    fi

    if ! grep -q '^nvidia ' /proc/modules; then
        log "加载 nvidia 模块 ..."
        modprobe nvidia || die "modprobe nvidia 失败"
        modprobe nvidia_uvm 2>/dev/null || true
        modprobe nvidia_drm 2>/dev/null || true
    fi

    # 等驱动自动绑定
    local i d
    for i in $(seq 1 10); do
        d=$(driver); [ "$d" = nvidia ] && break; sleep 0.5
    done
    if [ "$(driver)" != nvidia ]; then
        log "手动绑定 nvidia 驱动 ..."
        timeout 15 sh -c "echo '$GPU' > '$DRV/bind'" 2>/dev/null || true
        for i in $(seq 1 10); do [ "$(driver)" = nvidia ] && break; sleep 0.5; done
    fi
    [ "$(driver)" = nvidia ] || die "驱动绑定失败（当前驱动: $(driver)）"

    # 等 NVRM 初始化完成（必须用 probe：错误文本不能让循环提前 break）
    local out="" i
    for i in $(seq 1 30); do
        out=$(probe) && break
        out=""
        sleep 1
    done

    # 兜底：还不行就重载模块再试一轮（off 后 NVRM 状态偶发不恢复）
    if [ -z "$out" ]; then
        log "NVRM 未就绪，重载 nvidia 模块后重试 ..."
        modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
        sleep 1
        modprobe nvidia 2>/dev/null || true
        modprobe nvidia_uvm 2>/dev/null || true
        modprobe nvidia_drm 2>/dev/null || true
        for i in $(seq 1 20); do
            out=$(probe) && break
            out=""
            sleep 1
        done
    fi

    [ -n "$out" ] || die "nvidia-smi 无输出：驱动已绑定但设备不可用（建议重启）"
    log "已开启 ✓  $out"
}

# ---------------------------------------------------------------- off
do_off() {
    is_on || { log "已是关闭状态"; return 0; }

    local d; d=$(driver)
    if [ -n "$d" ] && [ "$d" != nvidia ]; then
        die "驱动状态异常（绑定的是 '$d'），拒绝操作；建议重启"
    fi

    local pids prot
    pids=$(holder_pids)
    if [ -n "$pids" ]; then
        if [ "$FORCE" = 1 ]; then
            log "--force：忽略占用，强行移除（可能损坏驱动状态）"
        elif [ "$KILL" = 1 ]; then
            prot=$(protected_holder)
            [ -n "$prot" ] && die "会话关键进程正在占用独显，拒绝终止: $prot"
            log "终止占用进程: $(echo $pids | tr '\n' ' ')"
            kill -TERM $pids 2>/dev/null
            local i
            for i in $(seq 1 5); do [ -z "$(holder_pids)" ] && break; sleep 1; done
            if [ -n "$(holder_pids)" ]; then
                log "仍有进程未退出，发送 SIGKILL"
                kill -KILL $pids 2>/dev/null
                sleep 1
            fi
            [ -n "$(holder_pids)" ] && die "仍被占用，无法关闭"
        else
            log "以下进程正在使用独显，拒绝关闭："
            holder_detail
            die "先关闭它们；或加 --kill（终止进程）/ --force（强行移除）"
        fi
    fi

    log "从 PCI 总线移除设备 ..."
    echo 1 > "$DEV/remove" 2>/dev/null || true
    local i
    for i in $(seq 1 40); do is_on || break; sleep 0.5; done
    is_on && die "移除失败：设备仍在总线上（驱动未释放），不要再反复试，建议重启"

    # 移除后卸载模块：彻底断电，并避免下次 on 时 NVRM 状态残留
    modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
    log "已关闭 ✓（功耗 ≈ 0）"
}

# ---------------------------------------------------------------- status/users
do_status() {
    echo "--- 独显状态 ---"
    kmod_ok || log "警告：当前内核 $(uname -r) 下没有 nvidia 模块文件"
    if is_on; then
        log "PCI: 存在，驱动: $(driver || echo 未绑定)"
    else
        log "PCI: 不存在（已关闭）"
    fi
    local out; out=$(probe)
    [ -n "$out" ] && log "nvidia-smi: $out" || log "nvidia-smi: 无设备"
    [ -f /sys/class/power_supply/AC/online ] && \
        log "电源: $([ "$(cat /sys/class/power_supply/AC/online)" = 1 ] && echo 插电 || echo 电池)"
    if is_on; then
        if [ -n "$(holder_pids)" ]; then
            log "占用进程："; holder_detail
        else
            log "无进程占用 ✓"
        fi
    fi
}

do_users() {
    echo "--- 占用独显的进程 ---"
    if ! ls /dev/nvidia* >/dev/null 2>&1; then
        log "没有 /dev/nvidia* → 独显未启用"; return 0
    fi
    if [ -n "$(holder_pids)" ]; then holder_detail; else log "无进程占用 ✓"; fi
}

# ---------------------------------------------------------------- wayle
do_wayle() {
    local u uid wl
    u=$(logname 2>/dev/null || printf '%s' "${SUDO_USER:-}")
    [ -n "$u" ] && [ "$u" != root ] || die "无法确定桌面用户（请用 sudo 从桌面会话调用）"
    uid=$(id -u "$u")
    wl=$(basename "$(ls /run/user/"$uid"/wayland-* 2>/dev/null | head -1)")
    [ -n "$wl" ] || die "找不到 WAYLAND_DISPLAY"
    sudo -u "$u" env XDG_RUNTIME_DIR="/run/user/$uid" WAYLAND_DISPLAY="$wl" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        wayle panel restart || die "wayle panel restart 失败"
    log "wayle 面板已重启"
}

# ---------------------------------------------------------------- 入口
CMD="${1:-status}"; shift || true

show_help() { awk 'NR>2 && /^#/ { sub(/^# ?/,""); print; next } NR>2 { exit }' "$0"; }

case "$CMD" in
    -h|--help|help) show_help; exit 0 ;;
esac

while [ $# -gt 0 ]; do
    case "$1" in
        --kill|-k)  KILL=1 ;;
        --force|-f) FORCE=1 ;;
        -h|--help|help) show_help; exit 0 ;;
        *) die "未知选项：$1（-h 查看帮助）" ;;
    esac
    shift
done

case "$CMD" in
    status) do_status ;;
    users)  do_users ;;
    on|off|reload|toggle|wayle)
        require_root "$CMD"
        if [ "$CMD" != wayle ]; then
            exec 9>"$LOCK" || die "无法创建锁文件 $LOCK"
            flock -n 9 || die "另一个 dgpu-power 正在运行"
        fi
        case "$CMD" in
            on)     do_on ;;
            off)    do_off ;;
            reload) do_off && sleep 1 && do_on ;;
            toggle) if is_on; then do_off; else do_on; fi ;;
            wayle)  do_wayle ;;
        esac
        # 状态变化后提示（不自动执行，避免成为故障点）
        case "$CMD" in
            on|off|reload|toggle) log "提示：如音频默认输出异常，运行 'sudo $0 wayle'" ;;
        esac
        ;;
    *) die "未知命令：$CMD（on/off/reload/toggle/status/users/wayle，-h 查看帮助）" ;;
esac

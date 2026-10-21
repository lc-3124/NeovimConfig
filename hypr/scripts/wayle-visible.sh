#!/usr/bin/env bash
# ============================================================================
# 隐藏 / 显示所有 wayle 状态栏（主实例 + 副屏独立实例）
# 用法: wayle-visible.sh hide|show
#
# 主实例走当前会话总线（wayle panel hide/show）；
# 副屏实例跑在独立 D-Bus 会话里，需按它的私有总线地址调用。
# ============================================================================
set -u
action="${1:-}"
case "$action" in
    hide|show) ;;
    *) echo "用法: $0 hide|show" >&2; exit 1;;
esac

# 1) 主实例（当前会话总线）
wayle panel "$action" >/dev/null 2>&1 || true

# 2) 副屏实例（独立 D-Bus 会话）：按 environ 精确匹配配置目录
uid=$(id -u)
for p in $(pgrep -u "$uid" -x wayle 2>/dev/null); do
    envp=$(tr '\0' '\n' < "/proc/$p/environ" 2>/dev/null) || continue
    printf '%s\n' "$envp" | grep -qx "XDG_CONFIG_HOME=$HOME/.config/wayle-hdmi" || continue
    bus=$(printf '%s\n' "$envp" | sed -n 's/^DBUS_SESSION_BUS_ADDRESS=//p')
    [ -n "$bus" ] || continue
    DBUS_SESSION_BUS_ADDRESS="$bus" wayle panel "$action" >/dev/null 2>&1 || true
done

exit 0

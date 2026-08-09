#!/usr/bin/env bash
# ============================================================================
# 锁屏并挂起：先显示 hyprlock（动态壁纸），再进入 suspend
# 已在锁屏状态时直接挂起（唤醒后锁屏仍在）
# 绑定: hypr/configure/keybind.lua  CTRL + ALT + L（locked=true）
# ============================================================================

if ! pgrep -x hyprlock >/dev/null 2>&1; then
    "$HOME/.config/hypr/scripts/lock.sh" &
    sleep 1
fi
systemctl suspend

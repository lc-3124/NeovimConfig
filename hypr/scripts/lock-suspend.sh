#!/usr/bin/env bash
# ============================================================================
# 锁屏并挂起：先显示 hyprlock（动态壁纸），再进入 suspend
# 唤醒后锁屏仍在，输入密码解锁
# 绑定: hypr/configure/keybind.lua  SUPER + SHIFT + L
# ============================================================================

"$HOME/.config/hypr/scripts/lock.sh" &
sleep 1
systemctl suspend

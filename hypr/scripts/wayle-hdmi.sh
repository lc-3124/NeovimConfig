#!/usr/bin/env bash
# ============================================================================
# 外接屏 HDMI-A-1 专用 wayle 实例（顶部横栏、仅工作区切换）
# ----------------------------------------------------------------------------
# wayle 的栏位置 [bar] location 是全局的，且 shell 有单例保护
# （com.wayle.shell → "Wayle shell is already running"）。为让外接屏用
# 顶部横栏、内置屏保持右侧竖栏，这里用：
#   独立 D-Bus 会话（dbus-run-session）   —— 绕过单例检查，且不抢主实例的
#                                            org.freedesktop.Notifications
#   独立 XDG_CONFIG_HOME                   —— 使用 ~/.config/wayle-hdmi 的配置
# 实例只服务 HDMI-A-1（见该配置里的 [[bar.layout]]）。
# 由 configure/env.lua 的 hyprland.start 调用。
# ============================================================================
set -u

exec dbus-run-session --config-file="$HOME/.config/wayle-hdmi/dbus.conf" -- env \
  XDG_CONFIG_HOME="$HOME/.config/wayle-hdmi" \
  XDG_STATE_HOME="$HOME/.local/state/wayle-hdmi" \
  wayle shell

#!/bin/sh
# ============================================================================
# 锁屏遮罩：全屏半透明窗口，给锁屏一个强烈的视觉切换。
#
# 「浮动 / 置顶 / 比屏幕更大 / 无装饰」由 Hyprland 窗口规则保证
#   → ~/.config/hypr/configure/typical.lua 里的 "lock-veil·浮动超大无装饰"
#   （class 匹配 ^lock-veil$，float + size 2200x1300 + move -140,-110 + decorate=false）
# 所以它不参与平铺、不挤压其它窗口，边框与圆角全部落在屏幕之外。
#
# 可调：OPACITY 越大越暗（1.0=全黑）；LIFE 存活秒数。
# ============================================================================
OPACITY=0.72
LIFE=2

setsid kitty --class lock-veil \
  -o background_opacity=${OPACITY} \
  -o hide_window_decorations=yes \
  -o font_size=1 \
  -o shell_integration=disabled \
  -o confirm_os_window_close=0 \
  sh -c "sleep ${LIFE}" >/dev/null 2>&1 &

exit 0

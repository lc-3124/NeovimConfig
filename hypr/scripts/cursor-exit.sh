#!/bin/sh
# cursor-exit.sh —— 退出光标模式：停移动、复位子图，并恢复进入前的鼠标状态
RT="${XDG_RUNTIME_DIR:-/tmp}"
rm -f "$RT/hypr-cursor-active"

# 恢复进入前的鼠标 grab 状态：
#   进入前是「已禁用物理鼠标」→ 重新启用 grab
#   进入前是「正常可用」→ 保持可用，不再无条件禁用
if [ "$(cat "$RT/hypr-cursor-grab-was-active" 2>/dev/null)" = "1" ]; then
  sudo systemctl start mouse-grab.service 2>/dev/null
fi
rm -f "$RT/hypr-cursor-grab-was-active"

# 指针恢复常态：不自动隐藏（切换模式前 Hyprland 的默认行为）
hyprctl eval 'hl.config({ cursor = { inactive_timeout = 0, hide_on_key_press = false }})' >/dev/null 2>&1

hyprctl dispatch 'hl.dsp.submap("reset")' >/dev/null 2>&1
hyprctl dismissnotify >/dev/null 2>&1

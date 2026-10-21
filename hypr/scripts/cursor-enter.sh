#!/bin/sh
# cursor-enter.sh —— 进入光标模式：指针移到当前聚焦屏中心，并切到 cursor 子图
RT="${XDG_RUNTIME_DIR:-/tmp}"
: > "$RT/hypr-cursor-active"                 # 通知 hypr-cursor 守护：进入光标模式
printf 'fast\n' > "$RT/hypr-cursor-speed"
# 光标模式全程要看得见指针：禁止超时隐藏、禁止按键隐藏
hyprctl eval 'hl.config({ cursor = { inactive_timeout = 0, hide_on_key_press = false }})' >/dev/null 2>&1
m=$(hyprctl -j monitors 2>/dev/null | jq -r '.[]|select(.focused==true)|"\(.x) \(.y) \(.width) \(.height)"' | head -1)
set -- $m
if [ -n "${1:-}" ]; then
  cx=$(( $1 + $3/2 )); cy=$(( $2 + $4/2 ))
  echo "$cx $cy" > "$RT/hypr-cursor-pos"   # 交接给 hypr-cursor 守护作为初始位置
  hyprctl dispatch "hl.dsp.cursor.move({ x = $cx, y = $cy })" >/dev/null 2>&1
fi
hyprctl dispatch 'hl.dsp.submap("cursor")' >/dev/null 2>&1

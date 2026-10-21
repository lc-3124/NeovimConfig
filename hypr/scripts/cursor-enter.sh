#!/bin/sh
# cursor-enter.sh —— 进入光标模式：指针移到当前聚焦屏中心，并切到 cursor 子图
printf 'fast\n' > "${XDG_RUNTIME_DIR:-/tmp}/hypr-cursor-speed"
m=$(hyprctl -j monitors 2>/dev/null | jq -r '.[]|select(.focused==true)|"\(.x) \(.y) \(.width) \(.height)"' | head -1)
set -- $m
if [ -n "${1:-}" ]; then
  hyprctl dispatch "hl.dsp.cursor.move({ x = $(( $1 + $3/2 )), y = $(( $2 + $4/2 )) })" >/dev/null 2>&1
fi
hyprctl dispatch 'hl.dsp.submap("cursor")' >/dev/null 2>&1

#!/bin/sh
# cursor-move.sh <left|down|up|right> —— 按当前速度档写方向到平滑守护
RT="${XDG_RUNTIME_DIR:-/tmp}"; F="$RT/hypr-cursor-speed"; STATE="$RT/hypr-smooth.state"
if [ "$(cat "$F" 2>/dev/null || echo fast)" = slow ]; then s=3; else s=18; fi
case "${1:-}" in
  left)  printf -- '-%s 0 0\n' "$s" > "$STATE" ;;
  right) printf -- '%s 0 0\n'  "$s" > "$STATE" ;;
  up)    printf -- '0 -%s 0\n' "$s" > "$STATE" ;;
  down)  printf -- '0 %s 0\n'  "$s" > "$STATE" ;;
esac

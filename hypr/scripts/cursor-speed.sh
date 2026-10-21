#!/bin/sh
# cursor-speed.sh [slow|fast] —— 设置光标速度档；不带参数则切换
RT="${XDG_RUNTIME_DIR:-/tmp}"; F="$RT/hypr-cursor-speed"
case "${1:-toggle}" in
  slow) echo slow > "$F" ;;
  fast) echo fast > "$F" ;;
  *)    [ "$(cat "$F" 2>/dev/null || echo fast)" = fast ] && echo slow > "$F" || echo fast > "$F" ;;
esac

#!/bin/sh
# cursor-speed.sh —— 切换光标模式快/慢速（静默）
RT="${XDG_RUNTIME_DIR:-/tmp}"; F="$RT/hypr-cursor-speed"
[ "$(cat "$F" 2>/dev/null || echo fast)" = fast ] && echo slow > "$F" || echo fast > "$F"

#!/bin/sh
# cursor-mv.sh —— 控制平滑 mover：cursor-mv.sh <dx> <dy> [wheel] | stop
RT="${XDG_RUNTIME_DIR:-/tmp}"; STATE="$RT/hypr-smooth.state"
if [ "${1:-stop}" = "stop" ]; then printf '0 0 0\n' > "$STATE"
else printf '%s %s %s\n' "${1:-0}" "${2:-0}" "${3:-0}" > "$STATE"; fi

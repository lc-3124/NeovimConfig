#!/bin/sh
# cursor-release.sh <left|down|up|right> —— 松开某方向（移除该方向标记）
RT="${XDG_RUNTIME_DIR:-/tmp}"; DIR="$RT/hypr-cursor-dirs"
case "${1:-}" in
  left|right|up|down) rm -f "$DIR/$1" ;;
esac

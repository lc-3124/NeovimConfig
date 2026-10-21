#!/bin/sh
# cursor-move.sh <left|down|up|right> —— 按住某方向（可多方向叠加成斜向）
# 每个按下的方向在 $RT/hypr-cursor-dirs/ 下留一个标记文件，
# 由 cursor-mover.sh 每帧读取并合成向量。
RT="${XDG_RUNTIME_DIR:-/tmp}"; DIR="$RT/hypr-cursor-dirs"
mkdir -p "$DIR"
case "${1:-}" in
  left|right|up|down) : > "$DIR/$1" ;;
esac

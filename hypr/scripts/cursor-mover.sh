#!/bin/bash
# cursor-mover.sh —— 平滑光标守护进程
#   读取 $RT/hypr-cursor-dirs/ 下被按住的方向标记，合成向量后约 60fps
#   经 dotoold 连续输出 mousemove。支持多方向叠加（如 left+up → 左上）。
#   斜向按 0.7 倍系数，避免比单向快 √2 倍。
#   由 Hyprland 自启动；无方向按下时不产生任何输入。
set -u
RT="${XDG_RUNTIME_DIR:-/tmp}"
DIR="$RT/hypr-cursor-dirs"
SPEED="$RT/hypr-cursor-speed"
PIDF="$RT/hypr-smooth.pid"
LOCK="$RT/hypr-smooth.lock"

exec 9>"$LOCK"
flock -n 9 || { echo "cursor-mover 已在运行"; exit 0; }   # 单实例

echo $$ > "$PIDF"
mkdir -p "$DIR"
cleanup() { rm -f "$DIR/left" "$DIR/right" "$DIR/up" "$DIR/down" 2>/dev/null; rm -f "$PIDF"; exit 0; }
trap cleanup TERM INT

while :; do
  dx=0; dy=0
  [ -e "$DIR/left" ]  && dx=$((dx - 1))
  [ -e "$DIR/right" ] && dx=$((dx + 1))
  [ -e "$DIR/up" ]    && dy=$((dy - 1))
  [ -e "$DIR/down" ]  && dy=$((dy + 1))

  if [ "$dx" -ne 0 ] || [ "$dy" -ne 0 ]; then
    if [ "$(cat "$SPEED" 2>/dev/null || echo fast)" = slow ]; then s=3; else s=18; fi
    if [ "$dx" -ne 0 ] && [ "$dy" -ne 0 ]; then
      s=$(( (s * 7 + 5) / 10 ))          # 斜向 ≈0.7 倍，保证合速度一致
      [ "$s" -lt 1 ] && s=1
    fi
    echo "mousemove $((dx * s)) $((dy * s))" | dotoolc
  fi
  sleep 0.016
done

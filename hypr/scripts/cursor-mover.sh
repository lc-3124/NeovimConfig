#!/bin/bash
# cursor-mover.sh —— 平滑光标/滚动守护进程
#   读状态文件（由 cursor-mv.sh 写），约 60fps 经 dotoold 连续 mousemove/wheel。
#   由 Hyprland 自启动；空闲（0 0 0）时不产生任何输入，只做一次文件读+睡眠。
set -u
RT="${XDG_RUNTIME_DIR:-/tmp}"
STATE="$RT/hypr-smooth.state"
PIDF="$RT/hypr-smooth.pid"
LOCK="$RT/hypr-smooth.lock"

exec 9>"$LOCK"
flock -n 9 || { echo "cursor-mover 已在运行"; exit 0; }   # 单实例
echo $$ > "$PIDF"
printf '0 0 0\n' > "$STATE"
trap 'printf "0 0 0\n" > "$STATE"; rm -f "$PIDF"; exit 0' TERM INT

while :; do
  read -r dx dy whl < "$STATE" 2>/dev/null || { dx=0; dy=0; whl=0; }
  dx=${dx:-0}; dy=${dy:-0}; whl=${whl:-0}
  if [ "$dx" != 0 ] || [ "$dy" != 0 ]; then echo "mousemove $dx $dy" | dotoolc; fi
  if [ "$whl" != 0 ]; then echo "wheel $whl" | dotoolc; fi
  sleep 0.016
done

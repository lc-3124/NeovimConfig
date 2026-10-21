#!/bin/sh
# cursor-mv.sh —— stop: 清空所有方向标记并停移动
# （其它参数保留旧接口，写入 hypr-smooth.state）
RT="${XDG_RUNTIME_DIR:-/tmp}"; DIR="$RT/hypr-cursor-dirs"; STATE="$RT/hypr-smooth.state"
if [ "${1:-stop}" = "stop" ]; then
  rm -f "$DIR/left" "$DIR/right" "$DIR/up" "$DIR/down" 2>/dev/null
  printf '0 0 0\n' > "$STATE"
else
  printf '%s %s %s\n' "${1:-0}" "${2:-0}" "${3:-0}" > "$STATE"
fi

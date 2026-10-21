#!/bin/sh
# cursor-act.sh —— 光标模式动作（点击/拖拽/一次性滚动）
case "${1:-}" in
  click)  echo "click ${2:-left}"       | dotoolc ;;
  down)   echo "buttondown ${2:-left}"  | dotoolc ;;
  up)     echo "buttonup ${2:-left}"    | dotoolc ;;
  scroll) if [ "${2:-up}" = up ]; then echo "wheel 5" | dotoolc; else echo "wheel -5" | dotoolc; fi ;;
esac

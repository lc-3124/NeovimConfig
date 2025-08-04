#!/bin/bash
hyprctl monitors -j | jq -r '.[] | "\(.y)"' | while read top_edge; do
  hyprctl cursorpos -j | while read pos; do
    y=$(echo "$pos" | jq '.y')
    if [ "$y" -le "$((top_edge + 5))" ]; then  # 当鼠标接近顶部（5px 缓冲区内）
      killall -SIGUSR1 waybar  # 发送显示信号
    else
      killall -SIGUSR2 waybar  # 发送隐藏信号
    fi
  done
done

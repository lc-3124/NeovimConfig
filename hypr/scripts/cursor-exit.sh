#!/bin/sh
# cursor-exit.sh —— 退出光标模式：停移动、复位子图，并把物理鼠标隐藏禁用
RT="${XDG_RUNTIME_DIR:-/tmp}"
printf '0 0 0\n' > "$RT/hypr-smooth.state" 2>/dev/null
rm -f "$RT/hypr-cursor-dirs/left" "$RT/hypr-cursor-dirs/right" "$RT/hypr-cursor-dirs/up" "$RT/hypr-cursor-dirs/down" 2>/dev/null
echo "buttonup left" | dotoolc 2>/dev/null
hyprctl eval 'hl.config({ cursor = { inactive_timeout = 0.5 }})' >/dev/null 2>&1   # 隐藏指针
sudo systemctl start mouse-grab.service 2>/dev/null                                 # 抓取禁用物理鼠标
hyprctl dispatch 'hl.dsp.submap("reset")' >/dev/null 2>&1
hyprctl dismissnotify >/dev/null 2>&1

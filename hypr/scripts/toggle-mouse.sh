#!/bin/sh
# toggle-mouse.sh —— 一键彻底开关鼠标
#   关闭：EVIOCGRAB 抓取所有指针设备（不产生任何事件）+ 隐藏指针图像
#   开启：释放 + 恢复指针显示
set -u
HIDE_TIMEOUT=0.5     # 无移动多少秒后隐藏指针

if systemctl is-active --quiet mouse-grab.service; then
    sudo systemctl stop mouse-grab.service
    hyprctl eval 'hl.config({cursor={inactive_timeout=0}})' >/dev/null 2>&1
    msg="鼠标已开启"
else
    sudo systemctl start mouse-grab.service
    hyprctl eval "hl.config({cursor={inactive_timeout=$HIDE_TIMEOUT}})" >/dev/null 2>&1
    msg="鼠标已关闭"
fi
echo "$msg"

#!/bin/bash
# 获取当前音频输出设备名称和图标
sink=$(pactl get-default-sink)
port=$(pactl list-sinks | grep -A20 "Name: $sink" \
      | grep "Active Port:" | awk '{print $3}')

case "$port" in
    *headphones*)  echo " Headphones" ;;
    *speaker*)     echo " Speaker"    ;;
    *hdmi*)        echo " HDMI"      ;;
    *usb*)         echo " USB Audio" ;;
    *)
        desc=$(pactl list-sinks | grep -A1 "Name: $sink" \
               | grep "Description:" | sed 's/.*Description: //')
        echo " ${desc:0:18}"
        ;;
esac

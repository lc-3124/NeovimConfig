#!/bin/bash
# 当 USB 3.0 集线器的 USB 2.0 配套部分没枚举出来时，强制复位
# 适用：Genesys Logic 集线器（05e3:0626 / 05e3:0610）

HUB_PATH="2-2"  # USB 3.0 集线器的 SuperSpeed 路径

if [ ! -d "/sys/bus/usb/devices/$HUB_PATH" ]; then
  notify-send "USB 复位" "未找到集线器 $HUB_PATH"
  exit 1
fi

echo -n "$HUB_PATH" | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null 2>&1
sleep 3
echo -n "$HUB_PATH" | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null 2>&1
sleep 3

if ls /dev/sr* >/dev/null 2>&1; then
  notify-send "USB 复位" "光驱已恢复: $(ls /dev/sr* 2>/dev/null)"
else
  notify-send "USB 复位" "完成，但光驱未检测到"
fi

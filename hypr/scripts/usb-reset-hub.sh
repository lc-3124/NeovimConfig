#!/bin/bash
# ============================================================================
# USB 集线器复位脚本
# 场景: USB 3.0 集线器的 USB 2.0 配套部分没被内核枚举出来（光驱等设备丢失）
# 适用: Genesys Logic 集线器（05e3:0626 / 05e3:0610）
# 原理: 通过 sysfs unbind/bind 强制重新枚举 USB 设备
# ============================================================================

HUB_PATH="2-2"  # USB 3.0 集线器的 SuperSpeed 路径（对应总线/端口）

if [ ! -d "/sys/bus/usb/devices/$HUB_PATH" ]; then
  notify-send "USB 复位" "未找到集线器 $HUB_PATH"
  exit 1
fi

# 解绑：从 USB 驱动中移除该设备
echo -n "$HUB_PATH" | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null 2>&1
sleep 3
# 重新绑定：让内核重新枚举设备
echo -n "$HUB_PATH" | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null 2>&1
sleep 3

# 检查光驱是否恢复
if ls /dev/sr* >/dev/null 2>&1; then
  notify-send "USB 复位" "光驱已恢复: $(ls /dev/sr* 2>/dev/null)"
else
  notify-send "USB 复位" "完成，但光驱未检测到"
fi

#!/bin/bash
# ============================================================================
# 低电量自动深度休眠（电量 <10% 时执行 hibernate）
# 深度休眠 = hibernate（休眠到磁盘，断电不丢数据，最省电）
# 充电中跳过；配合 low-battery-hibernate.timer 每分钟检查
# ============================================================================

battery=/sys/class/power_supply/BAT0

[ -d "$battery" ] || exit 0

# 正在充电 → 不休眠
status=$(cat "$battery/status" 2>/dev/null)
[ "$status" = "Charging" ] && exit 0

capacity=$(cat "$battery/capacity" 2>/dev/null)
[ -z "$capacity" ] && exit 0

[ "$capacity" -lt 10 ] && systemctl hibernate

exit 0

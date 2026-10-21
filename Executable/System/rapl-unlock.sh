#!/bin/bash
# ============================================================================
# rapl-unlock.sh —— 设定 EC MMIO-RAPL 功耗上限（默认 PL1 70W / PL2 90W）
#   EC 默认会把 constraint_0 锁到 30W；这里改成我们想要的上限。
#   强制写入（!= 目标即写），因为 EC 在 resume / 电源事件后会重设。
# ============================================================================
MMIO=/sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0
PS=/sys/devices/system/cpu/intel_pstate
PL1=${PL1:-50000000}      # 持续功耗 70W
PL2=${PL2:-60000000}      # 短时爆发 90W
POLL=${POLL:-5}
while :; do
    f="$MMIO/constraint_0_power_limit_uw"
    [ -w "$f" ] && { cur=$(cat "$f" 2>/dev/null); [ "$cur" != "$PL1" ] && echo "$PL1" > "$f" 2>/dev/null; }
    f="$MMIO/constraint_1_power_limit_uw"
    [ -w "$f" ] && { cur=$(cat "$f" 2>/dev/null); [ "$cur" != "$PL2" ] && echo "$PL2" > "$f" 2>/dev/null; }
    h="$PS/hwp_dynamic_boost"
    [ -w "$h" ] && [ "$(cat "$h" 2>/dev/null)" != "1" ] && echo 1 > "$h" 2>/dev/null
    sleep "$POLL"
done

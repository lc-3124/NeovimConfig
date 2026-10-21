#!/bin/bash
# ============================================================================
# power-policy.sh —— 按 CPU 占用动态放开功耗 + 按温度强制风扇
#   占用 > 50%  → 功耗全开 (PL1 115W / PL2 135W)，适合编译等重载
#   占用 < 45%  → 回 EC 默认 (PL1 30W / PL2 115W)   （45~50 保持，防抖）
#   温度 > 70°C → 风扇强制 level 7；< 66°C 才交回 auto（迟滞）
# ============================================================================
MMIO=/sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0
FAN=/proc/acpi/ibm/fan
POLL=1
HI_UTIL=50; LO_UTIL=45
FAN_HI=70;  FAN_LO=66
PL_LOW1=30000000;  PL_LOW2=115000000
PL_HI1=115000000;  PL_HI2=135000000

maxtemp() {
    local t=0 v h f
    for h in /sys/class/hwmon/hwmon*/; do
        [ "$(cat "$h/name" 2>/dev/null)" = coretemp ] || continue
        for f in "$h"temp*_input; do v=$(cat "$f" 2>/dev/null); [ -n "$v" ] && t=$(( v>t?v:t )); done
    done
    echo "$t"
}
read_cpu() { awk '/^cpu /{print ($2+$3+$4+$6+$7+$8), ($2+$3+$4+$5+$6+$7+$8)}' /proc/stat; }
set_pl() { # $1=PL1 $2=PL2
    local f
    f="$MMIO/constraint_0_power_limit_uw"; [ -w "$f" ] && [ "$(cat "$f" 2>/dev/null)" != "$1" ] && echo "$1" > "$f" 2>/dev/null
    f="$MMIO/constraint_1_power_limit_uw"; [ -w "$f" ] && [ "$(cat "$f" 2>/dev/null)" != "$2" ] && echo "$2" > "$f" 2>/dev/null
}
fan_set() { # $1=level
    echo "level $1" > "$FAN" 2>/dev/null
}

heavy=0; fan=auto
read b0 t0 < <(read_cpu)
while :; do
    sleep "$POLL"
    read b1 t1 < <(read_cpu)
    if [ "$t1" -gt "$t0" ]; then util=$(( (b1-b0)*100/(t1-t0) )); else util=0; fi
    b0=$b1; t0=$t1
    tc=$(( $(maxtemp) / 1000 ))

    # 占用迟滞
    [ "$util" -ge "$HI_UTIL" ] && heavy=1
    [ "$util" -lt "$LO_UTIL" ] && heavy=0
    if [ "$heavy" = 1 ]; then set_pl "$PL_HI1" "$PL_HI2"; else set_pl "$PL_LOW1" "$PL_LOW2"; fi
    # 不做软件降频：max_perf_pct 固定 100
    pctf=/sys/devices/system/cpu/intel_pstate/max_perf_pct
    [ -w "$pctf" ] && [ "$(cat "$pctf" 2>/dev/null)" != "100" ] && echo 100 > "$pctf" 2>/dev/null

    # 风扇：>70 拉满，<66 交回 auto
    if   [ "$tc" -gt "$FAN_HI" ]; then lvl=7
    elif [ "$tc" -lt "$FAN_LO" ]; then lvl=auto
    else lvl=""; fi
    if [ -n "$lvl" ] && [ "$lvl" != "$fan" ]; then
        fan_set "$lvl" && fan="$lvl"
    fi
done

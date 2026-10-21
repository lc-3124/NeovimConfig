#!/bin/bash
# ============================================================================
# cpu-power-mode.sh —— 按 CPU 占用率自动切换功耗策略
#   util < 50%（滞回：<=45 退出） → ECO  : EC 默认 30W + 85°C 温度墙
#   util >= 50%（滞回：>=55 进入）→ TURBO: PL1 115W / PL2 135W 全开，停用温度墙
# ============================================================================
MMIO=/sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0
PS=/sys/devices/system/cpu/intel_pstate
TURBO_ON=55
TURBO_OFF=45
POLL=2

read_cpu() { awk '/^cpu /{print ($2+$3+$4+$6+$7+$8), ($2+$3+$4+$5+$6+$7+$8)}' /proc/stat; }
set_pl() {
    [ -w "$MMIO/constraint_0_power_limit_uw" ] && echo "$1" > "$MMIO/constraint_0_power_limit_uw" 2>/dev/null
    [ -w "$MMIO/constraint_1_power_limit_uw" ] && echo "$2" > "$MMIO/constraint_1_power_limit_uw" 2>/dev/null
}

mode=""
apply() {
    if [ "$mode" = turbo ]; then
        set_pl 115000000 135000000
        [ -w "$PS/hwp_dynamic_boost" ] && echo 1 > "$PS/hwp_dynamic_boost" 2>/dev/null
        echo 0 > "$PS/no_turbo" 2>/dev/null; echo 100 > "$PS/max_perf_pct" 2>/dev/null
        systemctl stop thermal-cap.service 2>/dev/null
        logger -t cpu-power-mode "TURBO: PL1=115W PL2=135W, thermal-cap off"
    else
        set_pl 30000000 115000000
        [ -w "$PS/hwp_dynamic_boost" ] && echo 0 > "$PS/hwp_dynamic_boost" 2>/dev/null
        systemctl start thermal-cap.service 2>/dev/null
        logger -t cpu-power-mode "ECO: PL1=30W, 85C cap on"
    fi
}

read b0 t0 < <(read_cpu)
while :; do
    sleep "$POLL"
    read b1 t1 < <(read_cpu)
    if [ "$t1" -gt "$t0" ]; then util=$(( (b1-b0)*100/(t1-t0) )); else util=0; fi
    b0=$b1; t0=$t1

    if [ "$mode" != "turbo" ] && [ "$util" -ge "$TURBO_ON" ]; then
        mode=turbo; apply
    elif [ "$mode" = "turbo" ] && [ "$util" -le "$TURBO_OFF" ]; then
        mode=eco; apply
    elif [ -z "$mode" ]; then
        mode=eco; apply
    elif [ "$mode" = "turbo" ]; then
        set_pl 115000000 135000000     # EC 可能重设，turbo 期间持续兜底
    fi
done

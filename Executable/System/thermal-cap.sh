#!/bin/bash
# ============================================================================
# 温度软上限守护（intel_pstate，基于 max_perf_pct 频率封顶，保留睿频）
#   ≥ HIGH(85°C) → 快速下调频率上限
#   ≥ MID (82°C) → 缓降
#   ≤ LOW (76°C) → 缓慢恢复（+1/次），最高只回到 CEIL
#   CEIL 用于避开 90% 附近的“功耗墙悬崖”（90% 时负载会直接冲 100°C）
# 0.4s 轮询。目标：核心/封装峰值压在 HIGH 以内。
# 用法: thermal-cap.sh [HIGH] [MID] [LOW] [CEIL]
# ============================================================================
HIGH="${1:-85}"
MID="${2:-82}"
LOW="${3:-76}"
CEIL="${4:-88}"
PS=/sys/devices/system/cpu/intel_pstate

pct="$CEIL"
[ -w "$PS/no_turbo" ] && echo 0 > "$PS/no_turbo" 2>/dev/null   # 保留睿频，只用 pct 封顶

max_temp() {
    local t=0 v z h f
    for z in /sys/class/thermal/thermal_zone*; do
        [ "$(cat "$z/type" 2>/dev/null)" = "x86_pkg_temp" ] || continue
        v=$(cat "$z/temp" 2>/dev/null); [ -n "$v" ] && t=$(( v > t ? v : t ))
    done
    for h in /sys/class/hwmon/hwmon*; do
        [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ] || continue
        for f in "$h"/temp*_input; do
            v=$(cat "$f" 2>/dev/null); [ -n "$v" ] && t=$(( v > t ? v : t ))
        done
    done
    echo "$t"
}

apply() { [ -w "$PS/max_perf_pct" ] && echo "$pct" > "$PS/max_perf_pct" 2>/dev/null; }

apply
while :; do
    tc=$(( $(max_temp) / 1000 ))
    if   [ "$tc" -ge "$HIGH" ]; then pct=$(( pct - 10 )); [ "$pct" -lt 30 ] && pct=30
    elif [ "$tc" -ge "$MID"  ]; then pct=$(( pct - 2 ));  [ "$pct" -lt 30 ] && pct=30
    elif [ "$tc" -le "$LOW"  ]; then pct=$(( pct + 1 ));  [ "$pct" -gt "$CEIL" ] && pct="$CEIL"
    fi
    apply
    sleep 0.25
done

#!/bin/bash
# ============================================================================
# 风扇曲线 v3（ThinkPad thinkpad_acpi fan_control）—— 平滑版
#   · CPU 占用 ≥ LOAD_ON(%) → 目标最高档（打破 EC 功耗锁）
#   · 其余按“平滑温度”分档（迟滞 + EMA），并用速率限制逐级移动
#   · 升 ~1 级/秒、降 ~1 级/2.5 秒 —— 不再从 2 直跳 7
#   温度硬上限由 tcc-offset.service（~82°C）兜底
# ============================================================================
FAN=/proc/acpi/ibm/fan
POLL=1
LOAD_ON=98
LOAD_OFF=88
MAXI=6
STEP_UP_MS=1200
STEP_DOWN_MS=3000
EMA_NEW=18            # 平滑温度中新样本占比(%)

[ -w "$FAN" ] || { echo "fan 不可写"; exit 1; }

LEVELS=(auto 2 3 4 5 6 7)
UP=(0 62 65 68 71 75 81)
DOWN=(0 55 59 63 66 70 75)   # 降档阈值更低 → 迟滞更大

maxtemp() {
    local t=0 v h f
    for h in /sys/class/hwmon/hwmon*/; do
        [ "$(cat "$h/name" 2>/dev/null)" = coretemp ] || continue
        for f in "$h"temp*_input; do v=$(cat "$f" 2>/dev/null); [ -n "$v" ] && t=$(( v>t?v:t )); done
    done
    echo "$t"
}
read_cpu() { awk '/^cpu /{print ($2+$3+$4+$6+$7+$8), ($2+$3+$4+$5+$6+$7+$8)}' /proc/stat; }
now_ms() { date +%s%3N; }

idx=0; want=0; force=0; prev=""; last=0; ema=""
read b0 t0 < <(read_cpu)
while :; do
    sleep "$POLL"
    read b1 t1 < <(read_cpu)
    if [ "$t1" -gt "$t0" ]; then util=$(( (b1-b0)*100/(t1-t0) )); else util=0; fi
    b0=$b1; t0=$t1
    tc=$(( $(maxtemp) / 1000 ))
    if [ -z "$ema" ]; then ema=$tc; else ema=$(( (ema*(100-EMA_NEW) + tc*EMA_NEW)/100 )); fi

    [ "$util" -ge "$LOAD_ON" ]  && force=1
    [ "$util" -le "$LOAD_OFF" ] && force=0

    # 期望档位 want（基于平滑温度 ema，带迟滞）
    if   [ "$force" = 1 ]; then want=$MAXI
    elif [ "$want" -lt "$MAXI" ] && [ "$ema" -ge "${UP[$((want+1))]}" ]; then want=$((want+1))
    elif [ "$want" -gt 0 ] && [ "$ema" -le "${DOWN[$want]}" ]; then want=$((want-1))
    fi

    # 速率限制：idx 逐级向 want 靠拢
    n=$(now_ms)
    if   [ "$idx" -lt "$want" ] && [ $((n-last)) -ge "$STEP_UP_MS" ];   then idx=$((idx+1)); last=$n
    elif [ "$idx" -gt "$want" ] && [ $((n-last)) -ge "$STEP_DOWN_MS" ]; then idx=$((idx-1)); last=$n
    fi

    lvl=${LEVELS[$idx]}
    if [ "$lvl" != "$prev" ]; then
        if echo "level $lvl" > "$FAN" 2>/dev/null; then
            prev="$lvl"
            echo "$(date +%H:%M:%S) fan->$lvl (want=${LEVELS[$want]} ema=${ema} tc=${tc} util=${util}%)"
        fi
    fi
done

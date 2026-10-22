#!/bin/sh
# ============================================================================
# 每块屏幕各抓一张当前桌面，供 hyprlock 的 per-monitor background 使用。
# 模糊 / 亮度 / 对比度 / 色彩全部由 hyprlock 原生参数处理。
# 某块屏抓取失败（如开机瞬间桌面还没渲染）时，用静态兜底图。
# 产物：$XDG_RUNTIME_DIR/hyprlock-bg-<显示器名>.png
# ============================================================================
RUNDIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FALLBACK=/home/lc3124/.config/hypr/resource/images/lock-bg.png

monitors="$(hyprctl -j monitors 2>/dev/null | jq -r '.[].name')"
[ -n "$monitors" ] || monitors="eDP-1"

for m in $monitors; do
    out="$RUNDIR/hyprlock-bg-$m.png"
    tmp="$RUNDIR/.hl-shot-$m.png"
    if [ "${HYPRLOCK_BG_FALLBACK:-0}" = "1" ] \
       || ! grim -o "$m" "$tmp" 2>/dev/null || [ ! -s "$tmp" ]; then
        cp -f "$FALLBACK" "$out" 2>/dev/null || true
    else
        mv -f "$tmp" "$out"          # 原子替换，避免 hyprlock 读到写了一半的图
    fi
done
exit 0

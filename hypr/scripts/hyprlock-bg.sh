#!/bin/sh
# ============================================================================
# 只做一件事：抓一张当前桌面，交给 hyprlock 当背景。
# 模糊 / 亮度 / 对比度 / 色彩全部由 hyprlock 原生参数处理（就是开机那次的观感）。
# HYPRLOCK_BG_FALLBACK=1（开机瞬间桌面还没渲染）时用像素蕾米莉亚静帧兜底。
# ============================================================================
OUT=/run/user/1000/hyprlock-bg.png
TMP=/run/user/1000/.hl-shot.png
FALLBACK=/home/lc3124/.config/hypr/resource/images/lock-bg.png

if [ "${HYPRLOCK_BG_FALLBACK:-0}" = "1" ] || ! grim "$TMP" 2>/dev/null || [ ! -s "$TMP" ]; then
    cp -f "$FALLBACK" "$OUT" 2>/dev/null || exit 1
else
    mv -f "$TMP" "$OUT"          # 原子替换，避免 hyprlock 读到写了一半的图
fi
exit 0

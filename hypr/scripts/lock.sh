#!/usr/bin/env bash
# ============================================================================
# 锁屏脚本
#   1) 点亮屏幕
#   2) 立刻弹全屏半透明遮罩 —— 强烈提示"锁屏已触发"，同时盖住启动空档
#   3) 抓一张清晰桌面给 hyprlock 当背景
#   4) 锁屏；遮罩会在 lifeMs 后自行退出（那时已被 session-lock 隐藏）
# 同时被 META+L 锁屏 和 META+ALT+L 挂起 复用
# ============================================================================
D="$HOME/.config/hypr/scripts"

wlopm --on '*' 2>/dev/null
sleep 0.05

"$D/lock-veil.sh"

"$D/hyprlock-bg.sh" || true

exec hyprlock

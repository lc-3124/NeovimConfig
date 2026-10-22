#!/usr/bin/env bash
# ============================================================================
# 锁屏脚本
#   1) 点亮屏幕
#   2) 隐藏 wayle 状态栏，等窗口重排动画结束
#   3) 抓一张清晰桌面给 hyprlock 当背景
#   4) 锁屏；解锁后再把 wayle 显示回来
# 同时被 META+L 锁屏 和 META+ALT+L 挂起 复用
# ============================================================================
D="$HOME/.config/hypr/scripts"

wlopm --on '*' 2>/dev/null

"$D/wayle-visible.sh" hide
trap '"$D/wayle-visible.sh" show' EXIT

# 等窗口因状态栏隐藏而重排的动画结束，再抓图（否则会抓到重排中途）
sleep 0.4

"$D/hyprlock-bg.sh" || true

# --- 锁屏期间：60 秒无操作自动熄屏（走 META+ALT+K 的 toggle-screen.sh）---
# 有输入时自动点亮；解锁后立刻停掉这个 idle 守护
hypridle -c "$HOME/.config/hypr/hypridle-lock.conf" &
IDLE_PID=$!

hyprlock

"$D/wayle-visible.sh" show

kill "$IDLE_PID" 2>/dev/null
wait "$IDLE_PID" 2>/dev/null
wlopm --on '*' 2>/dev/null

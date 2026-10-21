#!/usr/bin/env bash
# ============================================================================
# 锁屏并挂起（META+ALT+L / CTRL+ALT+L）：
#   · 若尚未锁屏 → 先触发锁屏，等 hyprlock 真正起来后，再 suspend
#   · 若已在锁屏内 → 直接 suspend
# 唤醒后锁屏仍在，需解锁。
# ============================================================================
set -u

# 是否已处于锁屏状态：hyprlock 在跑，或 logind 报告会话已锁定
locked() {
    pgrep -x hyprlock >/dev/null 2>&1 && return 0
    [ "$(loginctl show-session "${XDG_SESSION_ID:-auto}" -p LockedHint --value 2>/dev/null)" = "yes" ]
}

if ! locked; then
    # 触发锁屏（lock.sh 会在后台跑到解锁为止）
    "$HOME/.config/hypr/scripts/lock.sh" &
    # 等 hyprlock 启动（最多 6s），确保「先锁屏，再休眠」
    for _ in $(seq 1 60); do
        locked && break
        sleep 0.1
    done
fi

systemctl suspend

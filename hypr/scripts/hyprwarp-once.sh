#!/bin/bash
# hyprwarp-once.sh —— 单实例启动 hyprwarp（先杀旧实例，避免叠加卡死）
set -u
pkill -x hyprwarp 2>/dev/null
for _ in $(seq 1 20); do pgrep -x hyprwarp >/dev/null 2>&1 || break; sleep 0.05; done
exec /usr/local/bin/hyprwarp

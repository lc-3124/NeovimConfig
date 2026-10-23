#!/bin/bash
# ============================================================================
# waydroid-start.sh —— 一键启动 Waydroid（Android 容器）并打开完整界面
#
# 依赖：
#   * waydroid + waydroid-image（extra / archlinuxcn）
#   * binderfs 已挂载（/etc/fstab 已配置，重启自动挂载）
#   * waydroid-container.service（已 enable）
#
# 用法：waydroid-start.sh
# ============================================================================
set -u

if ! systemctl is-active --quiet waydroid-container; then
    echo "[waydroid] 启动容器服务 ..."
    sudo systemctl start waydroid-container
    sleep 2
fi

if ! waydroid status 2>/dev/null | grep -q "Session:.*RUNNING"; then
    echo "[waydroid] 启动会话 ..."
    setsid waydroid session start >/dev/null 2>&1 &
    for _ in $(seq 1 20); do
        waydroid status 2>/dev/null | grep -q "Session:.*RUNNING" && break
        sleep 0.5
    done
fi

echo "[waydroid] 状态："
waydroid status 2>/dev/null | grep -E "Session|Container|IP address" | sed 's/^/  /'

echo "[waydroid] 打开界面 ..."
exec waydroid show-full-ui

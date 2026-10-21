#!/bin/sh
# ============================================================================
# 锁屏前准备指纹：把 fprintd 重启成干净实例。
# 为什么需要：fprintd 一旦跨挂起/被别处占用/设备半死不活，锁屏时第一次
# 触摸就会失败 —— 这正是"需要它的时候不工作"的主因。
# 权限：靠 /etc/sudoers.d/50-fprintd 里的免密规则（仅限这条命令）。
# ============================================================================
sudo -n /usr/bin/systemctl restart fprintd >/dev/null 2>&1

# 等它真的起来（最多 3 秒），避免 hyprlock 先于它发起验证
i=0
while [ $i -lt 30 ]; do
    systemctl is-active --quiet fprintd && break
    sleep 0.1
    i=$((i+1))
done
exit 0

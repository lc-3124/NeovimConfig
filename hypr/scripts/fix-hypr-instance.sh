#!/bin/bash
# fix-hypr-instance.sh — 修正当前终端的环境变量 HYPRLAND_INSTANCE_SIGNATURE
#
# 背景：Hyprland 重启/重登后，旧终端里 HYPRLAND_INSTANCE_SIGNATURE 仍是旧的实例号，
#       导致这些终端里 hyprctl 连不上当前实例。
# 原理：活实例的 socket 目录里必有 .socket.sock；旧实例只会残留 .socket2.sock。
#
# 用法（必须在当前 shell 里 source，才能 export 生效）：
#   source ~/.config/hypr/scripts/fix-hypr-instance.sh
#
# 验证：hyprctl activewindow

base="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr"
if [ ! -d "$base" ]; then
    echo "未找到 Hyprland socket 目录: $base" >&2
    return 1 2>/dev/null || exit 1
fi

old="${HYPRLAND_INSTANCE_SIGNATURE:-}"

# 收集拥有 .socket.sock 的活实例签名，取时间戳最新者
new_sig=$(for d in "$base"/*/; do
    [ -S "$d/.socket.sock" ] && basename "$d"
done | sort -r | head -1)

if [ -z "$new_sig" ]; then
    echo "没有找到活动的 Hyprland 实例" >&2
    return 1 2>/dev/null || exit 1
fi

export HYPRLAND_INSTANCE_SIGNATURE="$new_sig"
printf 'HYPRLAND_INSTANCE_SIGNATURE: %s\n' "${old:-<empty>}"
printf '                  修正为: %s\n' "$new_sig"
if [ "$old" != "$new_sig" ]; then
    echo "已修正 ✓ 用 'hyprctl activewindow' 验证"
fi
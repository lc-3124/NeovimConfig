#!/usr/bin/env bash
# ============================================================================
# 锁屏脚本：锁定前动态解析 Hyprland 当前壁纸，作为 hyprlock 背景
# 首选来源：awww 缓存（记录当前显示器真实壁纸，绝对路径）
# 备用来源：循环索引状态文件（images 目录）
# 视频壁纸：hyprlock 不支持视频，退化为静态壁纸
# ============================================================================

IMAGE_DIR="$HOME/.config/hypr/resource/images"
CFG="$HOME/.config/hypr/hyprlock.conf"
LIVE="/tmp/hyprlock-live.conf"

wall=""

# 1) 首选：awww 缓存里记录的当前壁纸
for f in "$HOME"/.cache/awww/*/*; do
    [[ -f "$f" ]] || continue
    p=$(tail -n1 "$f" 2>/dev/null)
    if [[ -n "$p" && -f "$p" ]]; then
        wall="$p"
        break
    fi
done

# 2) 备用：静态壁纸循环索引
if [[ -z "$wall" ]]; then
    idx=0
    [[ -f /tmp/hyprwall-sindex ]] && idx=$(</tmp/hyprwall-sindex)
    mapfile -t files < <(find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) 2>/dev/null | sort)
    if [[ ${#files[@]} -gt 0 ]]; then
        wall="${files[$(( idx % ${#files[@]} ))]}"
    fi
fi

if [[ -z "$wall" || ! -f "$wall" ]]; then
    echo "未找到当前壁纸，无法锁定" >&2
    exit 1
fi

# 生成临时配置并替换背景行（转义 & 等特殊字符）
cp "$CFG" "$LIVE"
escaped=$(printf '%s' "$wall" | sed 's/[&\\]/\\&/g')
sed -i "s|^    path = .*|    path = $escaped|" "$LIVE"

exec hyprlock -c "$LIVE"

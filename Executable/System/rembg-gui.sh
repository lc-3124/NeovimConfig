#!/bin/bash
# ============================================================================
# rembg-gui.sh —— 图形化 AI 抠图（ONNX Runtime，不依赖 torch）
#
# 用法：
#   rembg-gui.sh                 # 弹窗选图
#   rembg-gui.sh 图片.png        # 直接处理（thunar 右键动作调用）
#
# 环境变量：
#   REMBG_MODEL=isnet-general-use   默认，176MB，质量好
#   REMBG_MODEL=silueta             44MB，更快
#   REMBG_MODEL=birefnet-general    质量最好之一（约 900MB）
# ============================================================================
set -u

MODEL="${REMBG_MODEL:-isnet-general-use}"
BIN="$HOME/.local/bin/rembg"

if [ ! -x "$BIN" ]; then
    zenity --error --title="AI 抠图" \
        --text="找不到 rembg（$BIN）。\n请先安装。" 2>/dev/null
    exit 1
fi

IN=""
if [ $# -ge 1 ] && [ -f "$1" ]; then
    IN="$1"
else
    IN=$(zenity --file-selection --title="选择要抠图的图片" \
        --file-filter="图片 | *.png *.jpg *.jpeg *.webp *.bmp *.tif *.tiff" 2>/dev/null)
    [ -z "${IN:-}" ] && exit 0
fi

DIR=$(dirname "$IN")
BASE=$(basename "$IN")
STEM="${BASE%.*}"
OUT="$DIR/${STEM}-nobg.png"

# 防止覆盖原图
if [ "$IN" = "$OUT" ]; then
    OUT="$DIR/${STEM}-nobg-2.png"
fi

"$BIN" i -m "$MODEL" "$IN" "$OUT" 2>&1 \
    | zenity --progress --pulsate --auto-close --no-cancel \
             --title="AI 抠图" --text="模型：$MODEL\n处理：$BASE" 2>/dev/null

if [ -f "$OUT" ]; then
    zenity --info --title="AI 抠图" --text="完成\n\n$OUT" 2>/dev/null
else
    zenity --error --title="AI 抠图" --text="处理失败（可能模型下载中或网络问题）。" 2>/dev/null
fi

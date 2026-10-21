#!/bin/bash
# ============================================================================
# iopaint-web.sh —— 一键启动 IOPaint 本地 Web UI（浏览器自动打开）
#
# 功能：抠图/去背（BiRefNet）、擦除去物（LaMa）、局部重绘、
#       超分（RealESRGAN）、人脸修复（GFPGAN）、交互分割（SAM2.1）
#
# 用法：
#   iopaint-web.sh              # 默认 8080 端口、CPU
#   IOPAINT_PORT=8090 iopaint-web.sh
#   IOPAINT_DEVICE=cuda iopaint-web.sh   # 开了独显时可用
#   IOPAINT_REMOVE_BG=birefnet-portrait  # 人像抠图更准
# ============================================================================
set -u

PORT="${IOPAINT_PORT:-8080}"
DEV="${IOPAINT_DEVICE:-cpu}"
RBG="${IOPAINT_REMOVE_BG:-birefnet-general-lite}"
IN_DIR="${IOPAINT_INPUT:-$HOME/Pictures}"
OUT_DIR="${IOPAINT_OUTPUT:-$HOME/Pictures/iopaint-out}"
BIN="$HOME/.local/bin/iopaint"

if [ ! -x "$BIN" ]; then
    echo "找不到 iopaint：$BIN" >&2
    echo "请先安装：pipx install --python ~/.local/share/uv/python/cpython-3.12-linux-x86_64-gnu/bin/python3.12 iopaint" >&2
    exit 1
fi

mkdir -p "$OUT_DIR" "$IN_DIR"

ARGS=(
    start
    --host 127.0.0.1
    --port "$PORT"
    --inbrowser
    --model lama
    --device "$DEV"
    --output-dir "$OUT_DIR"
    --enable-remove-bg --remove-bg-device "$DEV" --remove-bg-model "$RBG"
    --enable-interactive-seg --interactive-seg-device "$DEV" --interactive-seg-model sam2_1_tiny
    --enable-realesrgan --realesrgan-device "$DEV" --realesrgan-model realesr-general-x4v3
)
# 如需人脸修复（GFPGAN，约 350MB），取消下面两行注释
# ARGS+=(--enable-gfpgan --gfpgan-device "$DEV")

ARGS+=(--input "$IN_DIR")

echo "[iopaint] http://127.0.0.1:$PORT  (device=$DEV, removebg=$RBG)"
echo "[iopaint] 输出目录: $OUT_DIR"
exec "$BIN" "${ARGS[@]}"

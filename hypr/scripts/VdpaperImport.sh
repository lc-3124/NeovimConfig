#!/usr/bin/env bash
# ============================================================================
# 视频壁纸导入/转码工具
# 将视频文件转码为 Hyprland 壁纸兼容格式（mpvpaper 播放）
# 转码参数: 1280px 宽度、15fps、libx264、crf28、无声
# 用法: ./VdpaperImport.sh /path/to/video.mp4
# 输出: ~/.config/hypr/resource/videos/<文件名>.mp4
# 依赖: ffmpeg, file, numfmt (coreutils)
# ============================================================================

set -e

if [[ $# -ne 1 ]]; then
    echo "用法: $0 /path/to/video.mp4"
    exit 1
fi

input="$1"

if [[ ! -f "$input" ]]; then
    echo "错误: 文件不存在: $input"
    exit 1
fi

mime=$(file --mime-type -b "$input" 2>/dev/null)
case "$mime" in
    video/*|application/octet-stream) ;;   # 常见视频格式
    *)
        echo "错误: 不是视频文件 (mime: $mime)"
        exit 1
        ;;
esac

output_dir="$HOME/.config/hypr/resource/videos"
mkdir -p "$output_dir"

base=$(basename "$input")
base="${base%.*}"
output="${output_dir}/${base}.mp4"

original_size=$(stat -c%s "$input" 2>/dev/null)

echo "转码中: $base"
echo "  输入:  $input ($(numfmt --to=iec $original_size 2>/dev/null || echo "$original_size B"))"
echo "  输出:  $output"
echo ""

# 视频转码：缩放至 1280px 宽（自适应高度）、15fps
# 编码: libx264, ultrafast 预设, crf28（较小体积）
# 无音频 (-an)
ffmpeg -y -i "$input" \
    -vf "scale=1280:-2,fps=15" \
    -c:v libx264 \
    -preset ultrafast \
    -crf 28 \
    -an \
    "$output" 2>&1 | tail -3

final_size=$(stat -c%s "$output" 2>/dev/null)

echo ""
echo "完成: $(numfmt --to=iec $final_size 2>/dev/null || echo "$final_size B") → $output"

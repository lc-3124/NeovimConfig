#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/video.mp4"
    exit 1
fi

input="$1"

if [[ ! -f "$input" ]]; then
    echo "Error: file not found: $input"
    exit 1
fi

mime=$(file --mime-type -b "$input" 2>/dev/null)
case "$mime" in
    video/*|application/octet-stream) ;;
    *)
        echo "Error: not a video file (mime: $mime)"
        exit 1
        ;;
esac

output_dir="$HOME/.config/hypr/resource/videos"
mkdir -p "$output_dir"

base=$(basename "$input")
base="${base%.*}"
output="${output_dir}/${base}.mp4"

original_size=$(stat -c%s "$input" 2>/dev/null)

echo "Transcoding: $base"
echo "  Input:  $input ($(numfmt --to=iec $original_size 2>/dev/null || echo "$original_size B"))"
echo "  Output: $output"
echo ""

ffmpeg -y -i "$input" \
    -vf "scale=1280:-2,fps=15" \
    -c:v libx264 \
    -preset ultrafast \
    -crf 28 \
    -an \
    "$output" 2>&1 | tail -3

final_size=$(stat -c%s "$output" 2>/dev/null)

echo ""
echo "Done: $(numfmt --to=iec $final_size 2>/dev/null || echo "$final_size B") → $output"

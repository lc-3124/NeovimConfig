#!/usr/bin/env bash

MONITOR="eDP-1"
IMAGE_DIR="$HOME/.config/hypr/resource/images"
VIDEO_DIR="$HOME/.config/hypr/resource/videos"
MODE_FILE="/tmp/hyprwall-mode"
SINDEX_FILE="/tmp/hyprwall-sindex"
VINDEX_FILE="/tmp/hyprwall-vindex"

kill_all() {
    killall mpvpaper 2>/dev/null
    killall mpv 2>/dev/null
}

get_files() {
    local dir="$1"
    shift
    find "$dir" -maxdepth 1 -type f "$@" 2>/dev/null | sort
}

next_idx() {
    local idx_file="$1"
    local count="$2"
    local idx=0
    if [[ -f "$idx_file" ]]; then
        idx=$(<"$idx_file")
    fi
    idx=$(( (idx + 1) % count ))
    echo "$idx" > "$idx_file"
    echo "$idx"
}

show_image() {
    local idx="$1"
    mapfile -t files < <(get_files "$IMAGE_DIR" \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))
    [[ ${#files[@]} -eq 0 ]] && exit 1
    awww img "${files[$idx]}" \
        -o "$MONITOR" \
        --transition-type grow \
        --transition-pos bottom-right \
        --transition-duration 0.8 \
        --transition-fps 24
}

show_video() {
    local idx="$1"
    mapfile -t files < <(get_files "$VIDEO_DIR" \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.gif' \))
    [[ ${#files[@]} -eq 0 ]] && exit 1
    mpvpaper -f -o "no-audio loop hwdec=vaapi framedrop=decoder+vo vd-lavc-framedrop=all vd-lavc-skiploopfilter=all display-fps-override=15 cache=no demuxer-max-bytes=512K demuxer-max-back-bytes=64K no-demuxer-thread" "$MONITOR" "${files[$idx]}"
}

case "${1:-next}" in
    toggle)
        # 读取当前模式
        mode="static"
        [[ -f "$MODE_FILE" ]] && mode=$(<"$MODE_FILE")

        # 切换模式
        if [[ "$mode" == "static" ]]; then
            echo "dynamic" > "$MODE_FILE"
            kill_all
            # 取当前视频索引
            vcount=$(get_files "$VIDEO_DIR" \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.gif' \) | wc -l)
            if [[ "$vcount" -gt 0 ]]; then
                vidx=0
                [[ -f "$VINDEX_FILE" ]] && vidx=$(<"$VINDEX_FILE")
                show_video "$vidx"
            fi
        else
            echo "static" > "$MODE_FILE"
            kill_all
            # 取当前图片索引
            scount=$(get_files "$IMAGE_DIR" \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l)
            if [[ "$scount" -gt 0 ]]; then
                sidx=0
                [[ -f "$SINDEX_FILE" ]] && sidx=$(<"$SINDEX_FILE")
                show_image "$sidx"
            fi
        fi
        ;;
    next|*)
        # 读取当前模式
        mode="static"
        [[ -f "$MODE_FILE" ]] && mode=$(<"$MODE_FILE")

        kill_all

        if [[ "$mode" == "static" ]]; then
            scount=$(get_files "$IMAGE_DIR" \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l)
            if [[ "$scount" -gt 0 ]]; then
                sidx=$(next_idx "$SINDEX_FILE" "$scount")
                show_image "$sidx"
            fi
        else
            vcount=$(get_files "$VIDEO_DIR" \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.gif' \) | wc -l)
            if [[ "$vcount" -gt 0 ]]; then
                vidx=$(next_idx "$VINDEX_FILE" "$vcount")
                show_video "$vidx"
            fi
        fi
        ;;
esac

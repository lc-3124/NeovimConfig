#!/usr/bin/env bash
# ============================================================================
# 双模式壁纸循环切换脚本
# 支持静态图片（awww）和视频（mpvpaper）两种壁纸模式
# 模式/索引状态保存在 /tmp/ 下，重启会话后重置
# 绑定:
#   Win+Z — 下一张壁纸               → hypr/configure/keybind.lua
#   Win+X — 切换静态/视频模式         → hypr/configure/keybind.lua
# 初始壁纸: 见 hypr/configure/env.lua 中 hyprland.start 事件
# ============================================================================

MONITOR="eDP-1"                                      # 内置显示器名称
IMAGE_DIR="$HOME/.config/hypr/resource/images"       # 静态壁纸目录
VIDEO_DIR="$HOME/.config/hypr/resource/videos"       # 视频壁纸目录
MODE_FILE="/tmp/hyprwall-mode"                       # 当前模式状态文件
SINDEX_FILE="/tmp/hyprwall-sindex"                   # 当前图片索引
VINDEX_FILE="/tmp/hyprwall-vindex"                   # 当前视频索引

# 终止所有壁纸进程
kill_all() {
    killall mpvpaper 2>/dev/null
    killall mpv 2>/dev/null
}

# 获取目录中符合扩展名的文件列表（排序）
get_files() {
    local dir="$1"
    shift
    find "$dir" -maxdepth 1 -type f "$@" 2>/dev/null | sort
}

# 循环递增索引（0 ~ count-1）
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

# 用 awww 设置静态壁纸（带 grow 过渡效果）
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

# 用 mpvpaper 播放视频壁纸（轻量参数，无音频）
show_video() {
    local idx="$1"
    mapfile -t files < <(get_files "$VIDEO_DIR" \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.gif' \))
    [[ ${#files[@]} -eq 0 ]] && exit 1
    mpvpaper -f -o "no-audio loop hwdec=vaapi framedrop=decoder+vo vd-lavc-framedrop=all vd-lavc-skiploopfilter=all display-fps-override=15 cache=no demuxer-max-bytes=512K demuxer-max-back-bytes=64K no-demuxer-thread" "$MONITOR" "${files[$idx]}"
}

case "${1:-next}" in
    toggle)
        # ====================================================================
        # 切换模式：静态 ↔ 视频
        # ====================================================================
        mode="static"
        [[ -f "$MODE_FILE" ]] && mode=$(<"$MODE_FILE")

        if [[ "$mode" == "static" ]]; then
            echo "dynamic" > "$MODE_FILE"
            kill_all
            vcount=$(get_files "$VIDEO_DIR" \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.gif' \) | wc -l)
            if [[ "$vcount" -gt 0 ]]; then
                vidx=0
                [[ -f "$VINDEX_FILE" ]] && vidx=$(<"$VINDEX_FILE")
                show_video "$vidx"
            fi
        else
            echo "static" > "$MODE_FILE"
            kill_all
            scount=$(get_files "$IMAGE_DIR" \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l)
            if [[ "$scount" -gt 0 ]]; then
                sidx=0
                [[ -f "$SINDEX_FILE" ]] && sidx=$(<"$SINDEX_FILE")
                show_image "$sidx"
            fi
        fi
        ;;
    next|*)
        # ====================================================================
        # 切换到下一张壁纸（当前模式下）
        # ====================================================================
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

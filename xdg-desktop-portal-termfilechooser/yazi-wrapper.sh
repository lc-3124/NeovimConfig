#!/usr/bin/env sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`
#
# 自定义增强：启动 kitty + yazi 后，通过 hyprctl 动态读取当前主显示器
# 逻辑分辨率（物理/scale），把窗口调整为屏幕 80% 大小并居中。
# 若不在 Hyprland 会话下运行则跳过调整，仅以默认方式启动。

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
debug="$6"

set -e

if [ "$debug" = 1 ]; then
    set -x
fi

cmd="yazi"
termcmd="${TERMCMD:-kitty --title 'termfilechooser'}"

if [ "$save" = "1" ]; then
    # save a file
    set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
    # upload files from a directory
    set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
elif [ "$multiple" = "1" ]; then
    # upload multiple files
    set -- --chooser-file="$out" "$path"
else
    # upload only 1 file
    set -- --chooser-file="$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    # escape double quotes
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    # escape special
    command="$command \"$escaped\""
done

# 通过通用 launch-float 启动文件选择器（kitty + yazi），
# 自动按屏幕逻辑尺寸 80% 浮动居中（Hyprland 下）
if command -v launch-float >/dev/null 2>&1; then
    launch-float '.title | contains("termfilechooser")' sh -c "$command"
else
    sh -c "$command"
fi

if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
        cat "$out"".1" > "$out"
        rm "$out"".1"
    else
        rm "$out"".1"
    fi
fi

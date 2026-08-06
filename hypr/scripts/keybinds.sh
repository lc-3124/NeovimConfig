#!/bin/bash

FILE="$HOME/.config/hypr/configure/keybind.lua"
[[ ! -f "$FILE" ]] && notify-send "错误" "找不到 keybind.lua" && exit 1

# 解析 keybind.lua，提取 hl.bind 之前紧邻的 -- 注释作为说明
entries=$(awk '
  /^-- / {
    comment = substr($0, 4)
    next
  }
  /^hl.bind\(/ {
    line = $0
    gsub(/^hl.bind\(/, "", line)
    gsub(/\),?$/, "", line)
    gsub(/mainMod \.\. " \+ /, "SUPER + ", line)
    gsub(/mainMod \.\. " \+/, "SUPER +", line)
    gsub(/" \.\. mainMod \.\. "/, "SUPER + ", line)
    gsub(/"/, "", line)
    gsub(/  +/, " ", line)

    key = line
    gsub(/,.*$/, "", key)
    gsub(/^ +| +$/, "", key)

    # 跳过鼠标、多媒体等非键盘快捷键
    if (key ~ /^mouse:|^XF86|^Print$|^SHIFT \+ Print|^CTRL \+ Print|^F[0-9]$/) {
      comment = ""
      next
    }
    # 跳过 for 循环中的占位变量
    if (key ~ /i$/) {
      comment = ""
      next
    }

    if (comment == "") {
      desc = line
      gsub(/^[^,]*, /, "", desc)
      gsub(/hl\.dsp\./, "", desc)
      if (length(desc) > 40) desc = substr(desc, 1, 40) "..."
      comment = desc
    }

    print key "  " comment
    comment = ""
  }
' "$FILE" | sort)

[[ -z "$entries" ]] && notify-send "错误" "没有提取到快捷键" && exit 1

selected=$(echo "$entries" | fuzzel --dmenu --prompt="快捷键: " --lines=20 --width=90 -f "monospace:size=10" 2>/dev/null)
[[ -z "$selected" ]] && exit 0

key=$(echo "$selected" | awk '{print $1}')
echo -n "$key" | wl-copy
notify-send "📋 已复制" "快捷键 [$key] 已复制到剪贴板"

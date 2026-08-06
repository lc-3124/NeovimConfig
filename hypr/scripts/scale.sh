#!/bin/bash
SIGN="${1:-+}"
MONITOR_FILE="$HOME/.config/hypr/configure/monitor.lua"
[[ ! -f "$MONITOR_FILE" ]] && notify-send "错误" "找不到 monitor.lua" && exit 1

# 获取当前聚焦的显示器名称
HIS=$(ls -t /run/user/1000/hypr/ | head -1)
export HYPRLAND_INSTANCE_SIGNATURE="$HIS"

target=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name')
[[ -z "$target" || "$target" == "null" ]] && notify-send "错误" "无法获取聚焦显示器" && exit 1

# 读取当前该显示器的缩放值
scale=$(awk -v t="$target" '
  /^hl\.monitor\(/ { in_block = 1; output = ""; sv = "" }
  in_block && match($0, /output *= *"([^"]+)"/, a) { output = a[1] }
  in_block && match($0, /scale *= *([0-9.]+)/, a) { sv = a[1] }
  /^}/ && in_block {
    in_block = 0
    if (output == t && sv != "") { print sv; found = 1 }
  }
  END { if (!found) exit 1 }
' "$MONITOR_FILE")

if [[ -z "$scale" ]]; then
  scale=$(awk '
    /^hl\.monitor\(/ { in_block = 1; sv = "" }
    in_block && match($0, /scale *= *([0-9.]+)/, a) { sv = a[1] }
    /^}/ && in_block { in_block = 0; if (sv != "") { print sv; exit } }
  ' "$MONITOR_FILE")
fi

[[ -z "$scale" ]] && notify-send "错误" "无法读取缩放值" && exit 1

new=$(echo "scale=2; $scale $SIGN 0.1" | bc -l)
new=$(echo "$new" | awk '{if ($1 < 0.5) print 0.5; else if ($1 > 3.0) print 3.0; else printf "%.2f", $1}')

# 修改配置文件中该显示器的 scale 行
awk -v t="$target" -v n="$new" '
  BEGIN { in_block = 0; output = "" }
  /^hl\.monitor\(/ { in_block = 1; output = "" }
  in_block && match($0, /output *= *"([^"]+)"/, a) { output = a[1] }
  in_block && output == t && match($0, /([ \t]*scale = *)[0-9.]+(.*)/, a) {
    $0 = a[1] n a[2]
  }
  /^}/ { in_block = 0 }
  { print }
' "$MONITOR_FILE" > "${MONITOR_FILE}.tmp" && mv "${MONITOR_FILE}.tmp" "$MONITOR_FILE"

hyprctl reload >/dev/null 2>&1
notify-send "缩放" "$target: $(printf "%.2f" $scale) → $(printf "%.2f" $new)"

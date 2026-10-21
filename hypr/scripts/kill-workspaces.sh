#!/usr/bin/env bash
#
# kill-workspaces.sh — 结束指定区间工作区里所有窗口对应的进程
#
# 用法：
#   kill-workspaces.sh              # 结束工作区 11..20 里的所有进程
#   kill-workspaces.sh 12 15        # 结束工作区 12..15
#   kill-workspaces.sh -n           # 只列出会杀哪些进程，不动手（dry-run）
#
set -uo pipefail

DRY=0
while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY=1; shift ;;
        *) break ;;
    esac
done
LO="${1:-11}"
HI="${2:-20}"

command -v hyprctl >/dev/null 2>&1 || { echo "找不到 hyprctl（当前不是 Hyprland 会话？）" >&2; exit 1; }

# 计算“不能杀”的祖先进程（脚本自身、终端、shell、Hyprland…）
# 注意：不能从 /proc/PID/stat 取 PPid——comm 含空格（如 "tmux: server"）时字段会错位，
# 因此统一从 /proc/PID/status 的 PPid: 读取。
excl=""
p=$$
while [ "${p:-0}" -gt 1 ] 2>/dev/null; do
    excl="$excl $p"
    p=$(awk '/^PPid:/{print $2; exit}' "/proc/$p/status" 2>/dev/null)
    [ -n "${p:-}" ] || break
done

# 收集目标工作区里窗口的 pid（python3 解析 JSON）
pids=$(hyprctl clients -j 2>/dev/null | python3 -c '
import json, sys
lo, hi = int(sys.argv[1]), int(sys.argv[2])
excl = {int(x) for x in sys.argv[3:]}
seen = set()
for c in json.load(sys.stdin):
    ws = (c.get("workspace") or {}).get("id", -1)
    pid = c.get("pid", 0)
    if lo <= ws <= hi and pid > 1 and pid not in seen and pid not in excl:
        seen.add(pid)
        print(pid)
' "$LO" "$HI" $excl)

if [ -z "$pids" ]; then
    echo "工作区 $LO-$HI 内没有可结束的窗口进程。"
    exit 0
fi

# 展开为进程树（含所有后代）
tree_of() {
    local pid=$1 child
    for child in $(pgrep -P "$pid" 2>/dev/null); do
        tree_of "$child"
    done
    echo "$pid"
}
all=""
for pid in $pids; do
    all="$all $(tree_of "$pid")"
done
all=$(printf '%s\n' $all | sort -un)

[ -z "$all" ] && { echo "没有找到进程。"; exit 0; }

echo "工作区 $LO-$HI 将结束以下进程："
for pid in $all; do
    printf '  %-7s %s\n' "$pid" "$(cat "/proc/$pid/comm" 2>/dev/null || echo '?')"
done

if [ "$DRY" = 1 ]; then
    echo "(dry-run，未结束任何进程)"
    exit 0
fi

kill -TERM $all 2>/dev/null
for _ in 1 2 3; do
    sleep 0.5
    alive=""
    for pid in $all; do
        kill -0 "$pid" 2>/dev/null && alive="$alive $pid"
    done
    [ -z "$alive" ] && break
    all="$alive"
done
if [ -n "${all:-}" ]; then
    kill -KILL $all 2>/dev/null
fi

echo "完成。"

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs"

echo "== 更新包名单 =="
echo

mkdir -p "$DOCS_DIR"

echo "[*] pacman 官方包 → docs/pacman-native.txt"
pacman -Qqen > "$DOCS_DIR/pacman-native.txt"
echo "    $(wc -l < "$DOCS_DIR/pacman-native.txt") packages"

echo "[*] AUR 包 → docs/aur-packages.txt"
pacman -Qqem > "$DOCS_DIR/aur-packages.txt"
echo "    $(wc -l < "$DOCS_DIR/aur-packages.txt") packages"

echo "[*] Winetricks → docs/winetricks-list.txt"
WINETRICKS_LOG="$HOME/.wine/winetricks.log"
if [ -f "$WINETRICKS_LOG" ]; then
  sort -u "$WINETRICKS_LOG" > "$DOCS_DIR/winetricks-list.txt"
  echo "    $(wc -l < "$DOCS_DIR/winetricks-list.txt") components"
else
  echo "    （未找到 $WINETRICKS_LOG，写入空列表）"
  > "$DOCS_DIR/winetricks-list.txt"
fi

echo
echo "== 完成 =="

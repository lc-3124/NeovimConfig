#!/bin/bash
# ============================================================================
# 软件包清单更新脚本
# 功能: 生成当前系统已装软件包清单到 docs/ 目录：
#   - pacman-native.txt  官方仓库包（pacman -Qqen）
#   - aur-packages.txt   AUR 包（pacman -Qqem）
#   - winetricks-list.txt  Wine 组件清单（winetricks.log）
#   - aur_install.sh     自动生成的 AUR 重装脚本（含全部 AUR 包）
# 用法: ~/NeovimConfig/update-pkg-lists.sh（backup-config.sh 会自动调用）
# ============================================================================
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

echo "[*] AUR 安装脚本 → docs/aur_install.sh"
{
  echo "#!/bin/bash"
  echo "# 自动生成于 $(date '+%Y-%m-%d %H:%M')，勿手改；来源: docs/aur-packages.txt"
  echo "# 用法: ./docs/aur_install.sh   # 安装全部 AUR 包（--needed 已装则跳过）"
  echo
  # 逐包生成 paru 安装命令，一个失败不影响后续
  while IFS= read -r pkg; do
    [ -n "$pkg" ] && echo "paru -S $pkg --needed --noconfirm ;"
  done < "$DOCS_DIR/aur-packages.txt"
} > "$DOCS_DIR/aur_install.sh"
chmod +x "$DOCS_DIR/aur_install.sh"
echo "    $(wc -l < "$DOCS_DIR/aur-packages.txt") packages"

echo
echo "== 完成 =="

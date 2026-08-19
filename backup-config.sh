#!/usr/bin/env bash
# ============================================================================
# 配置备份脚本（手动执行，单仓库模式）
#   1. 同步 ~/.config 下选中的软件配置 → NeovimConfig/extras/
#   2. 更新软件包清单（docs/）
#   3. git commit + push 到 GitHub
# 用法: ~/NeovimConfig/backup-config.sh
# ============================================================================
set -e

NC_DIR="$HOME/NeovimConfig"
CONFIG_DIR="$HOME/.config"
EXTRAS_DIR="$NC_DIR/extras"

# 需要备份的软件配置（小体积、纯配置、无账号数据）
APPS=(
  audacious btop cava dconf eog fcitx fooyin gsmartcontrol
  ibus input-remapper-2 kdiskmark libreoffice menus mpv ncmpcpp neofetch
  obs-studio peazip procps qBittorrent qt5ct qt6ct strawberry
  termusic Thunar xfce4 yarn
)

echo "== [1/3] 同步软件配置 → extras/ =="
mkdir -p "$EXTRAS_DIR"
for app in "${APPS[@]}"; do
  src="$CONFIG_DIR/$app"
  if [ -d "$src" ] || [ -e "$src" ]; then
    if command -v rsync >/dev/null; then
      # rsync 同步（保留权限，排除敏感/日志/缓存）
      rsync -a --delete \
        --exclude="*cookie*" --exclude="*token*" --exclude="*secret*" \
        --exclude="*.log" --exclude="*cache*" --exclude="bt_backup" \
        "$src/" "$EXTRAS_DIR/$app/" 2>/dev/null \
        || cp -a "$src" "$EXTRAS_DIR/$app"
    else
      # 无 rsync 时整目录复制
      rm -rf "$EXTRAS_DIR/$app"
      cp -a "$src" "$EXTRAS_DIR/$app"
    fi
    echo "    ✓ $app"
  fi
done

echo "== [2/3] 更新软件包清单 =="
if [ -x "$NC_DIR/update-pkg-lists.sh" ]; then
  "$NC_DIR/update-pkg-lists.sh"
fi

echo "== [3/3] 提交并推送 =="
cd "$NC_DIR"
git add -A
if git diff --cached --quiet; then
  echo "    无改动，跳过提交"
else
  git commit -q -m "backup: $(date +'%Y-%m-%d %H:%M') 配置快照 + 包清单"
  echo "    已提交: $(git rev-parse --short HEAD)"
fi
git push origin || echo "⚠️ 推送失败，检查网络/远端仓库"
echo "== 完成 =="

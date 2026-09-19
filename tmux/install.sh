#!/bin/bash
# tmux 配置安装脚本
# 用法: ./install.sh

set -e

TMUX_DIR="$HOME/.tmux"
TMUX_CONF="$HOME/.tmux.conf"
REPO_TMUX="$(cd "$(dirname "$0")" && pwd)"

echo "📦 安装 tmux 配置..."

# 备份现有配置
if [ -f "$TMUX_CONF" ] || [ -d "$TMUX_DIR" ]; then
    BACKUP_DIR="$HOME/.tmux.backup.$(date +%Y%m%d%H%M%S)"
    echo "🔁 备份现有配置到 $BACKUP_DIR"
    [ -f "$TMUX_CONF" ] && mv "$TMUX_CONF" "$BACKUP_DIR/"
    [ -d "$TMUX_DIR" ] && mv "$TMUX_DIR" "$BACKUP_DIR/"
fi

# 创建 ~/.tmux 目录
mkdir -p "$TMUX_DIR"

# 安装配置文件
cp "$REPO_TMUX/.tmux.conf" "$TMUX_CONF"
echo "✅ 配置文件已安装: $TMUX_CONF"

# 安装插件
if [ -d "$REPO_TMUX/plugins" ]; then
    echo "📦 复制 TPM 插件..."
    cp -r "$REPO_TMUX/plugins" "$TMUX_DIR/"
    echo "✅ 插件已安装"
fi

echo ""
echo "🎉 tmux 配置安装完成！"
echo "运行以下命令加载配置："
echo "  tmux source ~/.tmux.conf"
echo ""
echo "如果需要安装 TPM 插件："
echo "  打开 tmux 后按 prefix + I (大写 i)"
echo ""

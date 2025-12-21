#!/bin/bash
set -e

# ========= 基础变量 =========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_SUFFIX=".BAK.$(date +%s)"

echo "== Dotfiles installer =="
echo "Source: $SCRIPT_DIR"
echo

# ========= 工具函数 =========
link_config() {
    local name="$1"
    local source="$SCRIPT_DIR/$name"
    local target="$CONFIG_DIR/$name"

    echo "[*] Processing $name"

    if [ ! -e "$source" ]; then
        echo "    [!] Source not found: $source"
        return
    fi

    if [ -L "$target" ]; then
        echo "    - Removing existing symlink"
        rm "$target"

    elif [ -d "$target" ]; then
        echo "    - Backing up existing directory"
        mv "$target" "$target$BACKUP_SUFFIX"

    elif [ -e "$target" ]; then
        echo "    - Backing up existing file"
        mv "$target" "$target$BACKUP_SUFFIX"
    fi

    ln -s "$source" "$target"
    echo "    ✓ Linked $target → $source"
    echo
}

# ========= 开始安装 =========
mkdir -p "$CONFIG_DIR"

link_config hypr
link_config nvim
link_config waybar

# tmux 是特殊的（~/.tmux.conf）
TMUX_SOURCE="$SCRIPT_DIR/tmux/tmux.conf"
TMUX_TARGET="$HOME/.tmux.conf"

echo "[*] Processing tmux"
if [ -f "$TMUX_SOURCE" ]; then
    if [ -L "$TMUX_TARGET" ]; then
        rm "$TMUX_TARGET"
    elif [ -f "$TMUX_TARGET" ]; then
        mv "$TMUX_TARGET" "$TMUX_TARGET$BACKUP_SUFFIX"
    fi
    ln -s "$TMUX_SOURCE" "$TMUX_TARGET"
    echo "    ✓ Linked tmux config"
else
    echo "    [!] tmux.conf not found"
fi

echo
echo "== Done =="


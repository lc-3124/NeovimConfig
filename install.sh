#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_SUFFIX=".BAK.$(date +%s)"

echo "== Dotfiles Installer =="
echo "Source: $SCRIPT_DIR"
echo

link_config() {
    local name="$1"
    local source="$SCRIPT_DIR/$name"
    local target="$CONFIG_DIR/$name"

    echo "[*] Processing $name"

    if [ ! -d "$source" ]; then
        echo "    [!] Source not found: $source"
        return
    fi

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    elif [ -e "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    fi

    ln -s "$source" "$target"
    echo "    ✓ Linked $target → $source"
    echo
}

link_file() {
    local source="$1"
    local target="$2"

    if [ ! -f "$source" ]; then
        echo "    [!] Source not found: $source"
        return
    fi

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    fi

    ln -s "$source" "$target"
    echo "    ✓ Linked $target"
}

mkdir -p "$CONFIG_DIR"

link_config hypr
link_config nvim
link_config waybar
link_config kitty

# zsh — 只 link .zshrc，秘密文件和 zshrc.d 保持原位
link_file "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

# 安装 secrets.zsh 示例（如用户尚无）
if [ ! -f "$HOME/.config/zsh/secrets.zsh" ]; then
    mkdir -p "$HOME/.config/zsh"
    cp "$SCRIPT_DIR/zsh/secrets.zsh.example" "$HOME/.config/zsh/secrets.zsh"
    chmod 600 "$HOME/.config/zsh/secrets.zsh"
    echo "    ☕ Created ~/.config/zsh/secrets.zsh — please fill in your API keys"
fi

# 安装 zshrc.d 脚本
if [ -d "$SCRIPT_DIR/zsh/zshrc.d" ]; then
    mkdir -p "$HOME/.config/zshrc.d"
    for f in "$SCRIPT_DIR/zsh/zshrc.d/"*.sh; do
        cp "$f" "$HOME/.config/zshrc.d/"
    done
    echo "    ✓ Installed zshrc.d scripts"
fi

# tmux 特殊处理
echo "[*] Processing tmux"
TMUX_SOURCE_CONF="$SCRIPT_DIR/tmux/.tmux.conf"
TMUX_TARGET_CONF="$HOME/.tmux.conf"
TMUX_SOURCE_PLUGINS="$SCRIPT_DIR/tmux/plugins"
TMUX_TARGET_PLUGINS="$HOME/.tmux/plugins"

if [ -f "$TMUX_SOURCE_CONF" ]; then
    if [ -L "$TMUX_TARGET_CONF" ]; then
        rm "$TMUX_TARGET_CONF"
    elif [ -f "$TMUX_TARGET_CONF" ]; then
        mv "$TMUX_TARGET_CONF" "$TMUX_TARGET_CONF$BACKUP_SUFFIX"
    fi
    ln -s "$TMUX_SOURCE_CONF" "$TMUX_TARGET_CONF"
    echo "    ✓ Linked tmux.conf"
fi

if [ -d "$TMUX_SOURCE_PLUGINS" ]; then
    mkdir -p "$HOME/.tmux"
    if [ -L "$TMUX_TARGET_PLUGINS" ]; then
        rm "$TMUX_TARGET_PLUGINS"
    elif [ -d "$TMUX_TARGET_PLUGINS" ]; then
        mv "$TMUX_TARGET_PLUGINS" "$TMUX_TARGET_PLUGINS$BACKUP_SUFFIX"
    fi
    ln -s "$TMUX_SOURCE_PLUGINS" "$TMUX_TARGET_PLUGINS"
    echo "    ✓ Linked tmux plugins"
fi
echo

echo "== Done =="
echo
echo "Post-install:"
echo "  tmux: tmux source ~/.tmux.conf"
echo "  hypr: hyprctl reload"
echo "  waybar: killall waybar && waybar &"
echo "  zsh: 重新打开终端或 exec zsh"
echo
echo "📌 别忘了填写 API 密钥："
echo "   ~/.config/zsh/secrets.zsh"

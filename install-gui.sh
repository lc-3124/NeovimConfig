#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_SUFFIX=".BAK.$(date +%s)"

echo "== GUI Software Installer (hypr, waybar, fcitx5, kitty) =="
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
    echo "    Linked $target -> $source"
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
    echo "    Linked $target"
}

mkdir -p "$CONFIG_DIR"

# GUI: Hyprland
link_config hypr

# GUI: Waybar
link_config waybar

# GUI: Kitty (terminal emulator)
link_config kitty

# GUI: Fcitx5
link_config fcitx5

# GUI: Fcitx5 themes -> ~/.local/share/fcitx5/themes/
echo "[*] Deploying fcitx5 themes"
FCITX5_THEME_DIR="$HOME/.local/share/fcitx5/themes"
FCITX5_THEME_SOURCE="$SCRIPT_DIR/fcitx5/themes"
if [ -d "$FCITX5_THEME_SOURCE" ]; then
    mkdir -p "$FCITX5_THEME_DIR"
    for theme in "$FCITX5_THEME_SOURCE"/*/; do
        theme_name="$(basename "$theme")"
        target="$FCITX5_THEME_DIR/$theme_name"
        if [ -L "$target" ]; then
            rm "$target"
        elif [ -d "$target" ]; then
            mv "$target" "$target$BACKUP_SUFFIX"
        fi
        ln -s "$theme" "$target"
        echo "    Linked fcitx5 theme: $theme_name"
    done
fi
echo

# GUI: systemd user drop-ins
echo "[*] Deploying systemd user overrides"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SYSTEMD_SOURCE="$SCRIPT_DIR/systemd/user"
if [ -d "$SYSTEMD_SOURCE" ]; then
    find "$SYSTEMD_SOURCE" -type f -name "*.conf" | while read -r f; do
        relative="${f#$SYSTEMD_SOURCE/}"
        target="$SYSTEMD_USER_DIR/$relative"
        mkdir -p "$(dirname "$target")"
        cp "$f" "$target"
        echo "    Copied $relative"
    done
    systemctl --user daemon-reload 2>/dev/null || true
fi
echo

echo "== GUI install complete =="
echo
echo "Post-install:"
echo "  hypr:   hyprctl reload"
echo "  waybar: killall waybar && waybar &"
echo "  fcitx5: fcitx5 -r"

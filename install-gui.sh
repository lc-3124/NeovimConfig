#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_SUFFIX=".BAK.$(date +%s)"

echo "== GUI Software Installer (hypr, wayle, fcitx5, kitty, gtk) =="
echo
echo "⚠️  本脚本不恢复 Wine/Winetricks，参见 docs/winetricks-list.txt"
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

# GUI: Wayle (Wayland shell / 状态栏，由 hypr 启动)
echo "[*] Deploying wayle"
mkdir -p "$CONFIG_DIR/wayle"
link_file "$SCRIPT_DIR/wayle/config.toml" "$CONFIG_DIR/wayle/config.toml"
echo

# GUI: Fuzzel (application launcher)
link_config fuzzel

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

# GUI: Fcitx5 anytalk 密钥配置（从模板，不覆盖已有）
echo "[*] Deploying fcitx5 anytalk config"
ANYTALK_TARGET="$CONFIG_DIR/fcitx5/conf/anytalk.conf"
ANYTALK_TEMPLATE="$SCRIPT_DIR/fcitx5/conf/anytalk.conf.example"
if [ -f "$ANYTALK_TEMPLATE" ] && [ ! -f "$ANYTALK_TARGET" ]; then
    cp "$ANYTALK_TEMPLATE" "$ANYTALK_TARGET"
    echo "    Created anytalk.conf from template"
    echo "    >>> 请编辑 $ANYTALK_TARGET 填入 AppID / AccessToken / SecretKey"
elif [ -f "$ANYTALK_TARGET" ]; then
    echo "    anytalk.conf already exists, skipped"
fi
echo

# GUI: GTK themes
echo "[*] Deploying GTK theme configs"
link_file "$SCRIPT_DIR/gtk/gtkrc-2.0" "$HOME/.gtkrc-2.0"
link_file "$SCRIPT_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
link_file "$SCRIPT_DIR/gtk/gtk-3.0/gtk.css" "$CONFIG_DIR/gtk-3.0/gtk.css"
link_file "$SCRIPT_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini"
link_file "$SCRIPT_DIR/gtk/Kvantum/kvantum.kvconfig" "$CONFIG_DIR/Kvantum/kvantum.kvconfig"
link_file "$SCRIPT_DIR/gtk/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
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

# GUI: Screenshot script
echo "[*] Deploying screenshot script"
mkdir -p "$HOME/.local/bin"
link_file "$SCRIPT_DIR/hypr/scripts/screenshot" "$HOME/.local/bin/screenshot"
echo

# GUI: WirePlumber 蓝牙音频
echo "[*] Deploying WirePlumber bluetooth config"
WP_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
WP_SOURCE="$SCRIPT_DIR/wireplumber/51-bluetooth-buffer.conf"
if [ -f "$WP_SOURCE" ]; then
    mkdir -p "$WP_DIR"
    link_file "$WP_SOURCE" "$WP_DIR/51-bluetooth-buffer.conf"
fi
echo

echo "== GUI install complete =="
echo
echo "Post-install:"
echo "  hypr:   hyprctl reload"
echo "  wayle:  wayle panel start（hypr 已自启动，手动重启用 panel restart）"
echo "  fcitx5: fcitx5 -r"
echo "  wireplumber: systemctl --user restart wireplumber"
echo "  screenshot: Print (region), Shift+Print (full), Ctrl+Print (focused)"
echo
echo "手动配置："
echo "  Fcitx5 AnyTalk 语音输入 → cp fcitx5/conf/anytalk.conf.example ~/.config/fcitx5/conf/anytalk.conf"
echo "                           然后填入火山引擎 AppID / AccessToken / SecretKey"

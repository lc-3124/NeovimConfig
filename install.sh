#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Dotfiles Installer =="
echo "Source: $SCRIPT_DIR"
echo

usage() {
    echo "Usage: $0 [tui|gui|all]"
    echo
    echo "  tui  仅安装 TUI 软件配置 (nvim, tmux, zsh)"
    echo "  gui  仅安装 GUI 软件配置 (hypr, waybar, fcitx5, kitty)"
    echo "  all  安装全部 (默认)"
    echo
    exit 0
}

case "${1:-all}" in
    tui)
        bash "$SCRIPT_DIR/install-tui.sh"
        ;;
    gui)
        bash "$SCRIPT_DIR/install-gui.sh"
        ;;
    all)
        bash "$SCRIPT_DIR/install-tui.sh"
        bash "$SCRIPT_DIR/install-gui.sh"
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Unknown option: $1"
        usage
        ;;
esac

echo "== All done =="

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Dotfiles Installer =="
echo "Source: $SCRIPT_DIR"
echo
echo "⚠️  注意：本脚本不涉及 Wine / Winetricks 的恢复。"
echo "    Winetricks 已安装列表见 docs/winetricks-list.txt，需手动处理。"
echo "    蓝牙音频配置见 docs/audio.md，部署后需 systemctl --user restart wireplumber。"
echo

usage() {
    echo "Usage: $0 [tui|gui|all]"
    echo
    echo "  tui  仅安装 TUI 软件配置 (nvim, tmux, zsh)"
    echo "  gui  仅安装 GUI 软件配置 (hypr, waybar, wayle, fcitx5, kitty)"
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
echo
echo "========================================"
echo "  安装后手动配置"
echo "========================================"
echo
echo "以下凭据文件不包含在仓库中，需要你在对应目录自行创建或填写："
echo
echo "  1. Shell API 密钥"
echo "     cp zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh"
echo "     然后编辑填入 DEEPSEEK_API_KEY、TAVILY_API_KEY 等"
echo "     （此文件已加入 .gitignore，不会泄露）"
echo
echo "  2. Fcitx5 AnyTalk 语音输入"
echo "     cp fcitx5/conf/anytalk.conf.example ~/.config/fcitx5/conf/anytalk.conf"
echo "     然后填入火山引擎 AppID / AccessToken / SecretKey"
echo "     （此文件已加入 .gitignore，不会泄露）"
echo
echo "  3. Winetricks 组件"
echo "     如果使用 Wine，用 winetricks 重新安装列表中的组件："
echo "     cat docs/winetricks-list.txt"
echo

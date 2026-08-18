#!/bin/bash
# ============================================================
#  Dotfiles Installer —— 一键部署配置文件
# ============================================================
#  作用：把本仓库（NeovimConfig）里的配置文件
#       通过「符号链接」方式部署到 ~/.config 等位置，
#       所有配置源文件保留在仓库中，便于用 git 统一管理。
#
#  用法：./install.sh [tui|gui|all]
#    tui  仅安装 TUI 软件配置 (nvim, tmux, zsh)
#    gui  仅安装 GUI 软件配置 (hypr, wayle, fuzzel, kitty, fcitx5, gtk, systemd, wireplumber)
#    all  安装全部（默认）
#
#  特性：
#    - 幂等：重复运行不会产生垃圾文件，已有软链接会直接覆盖
#    - 安全：目标位置若已存在真实文件/目录，先备份为 *.BAK.<时间戳>
#    - 部署的是符号链接，改仓库文件即改系统配置
# ============================================================

# set -e：任一命令失败立即退出，避免「装一半」留下半成品状态
set -e

# SCRIPT_DIR：脚本自身所在目录（绝对路径）
#   BASH_SOURCE[0] 在脚本里指向脚本路径，dirname 取目录，cd 后 pwd 得到绝对路径。
#   这样无论从哪里调用本脚本，都能正确定位仓库里的配置文件。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# CONFIG_DIR：用户级配置文件根目录，即 ~/.config
CONFIG_DIR="$HOME/.config"
# BACKUP_SUFFIX：备份后缀，带时间戳，保证每次备份的文件名不重复
BACKUP_SUFFIX=".BAK.$(date +%s)"

# 开头横幅：向用户交代清楚本脚本的边界
echo "== Dotfiles Installer =="
echo "Source: $SCRIPT_DIR"
echo
# ⚠️ 提醒：Wine 相关（Winetricks 组件、蓝牙音频）需要手动处理，脚本不覆盖
echo "⚠️  注意：本脚本不涉及 Wine / Winetricks 的恢复。"
echo "    Winetricks 已安装列表见 docs/winetricks-list.txt，需手动处理。"
echo "    蓝牙音频配置见 docs/audio.md，部署后需 systemctl --user restart wireplumber。"
echo

# usage：打印帮助信息后退出
usage() {
    echo "Usage: $0 [tui|gui|all]"
    echo
    echo "  tui  仅安装 TUI 软件配置 (nvim, tmux, zsh)"
    echo "  gui  仅安装 GUI 软件配置 (hypr, wayle, fuzzel, kitty, fcitx5, gtk, systemd, wireplumber, qq)"
    echo "  all  安装全部 (默认)"
    echo
    exit 0
}

# ------------------------------------------------------------
# link_config：把一个「配置目录」链接到 ~/.config 下
#   用法：link_config <目录名>
#   例如 link_config hypr → ln -s 仓库/hypr ~/.config/hypr
# ------------------------------------------------------------
link_config() {
    local name="$1"                 # 配置名，如 hypr / nvim / kitty
    local source="$SCRIPT_DIR/$name" # 仓库里的源目录
    local target="$CONFIG_DIR/$name" # 系统里的目标目录

    echo "[*] Processing $name"

    # 源目录不存在就跳过（可能是未启用/已移除的软件配置）
    if [ ! -d "$source" ]; then
        echo "    [!] Source not found: $source"
        return
    fi

    # 处理目标位置已有的旧内容：
    #   已是软链接 → 直接删（覆盖）
    #   真实目录/文件 → 改名备份（保留原内容，安全回退）
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    elif [ -e "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    fi

    # 建立软链接，仓库即源头
    ln -s "$source" "$target"
    echo "    Linked $target -> $source"
    echo
}

# ------------------------------------------------------------
# link_file：把一个「文件」链接到任意目标路径
#   用法：link_file <源文件> <目标文件>
#   用于无法用 link_config 覆盖的场景（如 ~/.zshrc、~/.gtkrc-2.0）
# ------------------------------------------------------------
link_file() {
    local source="$1"   # 仓库里的源文件
    local target="$2"   # 目标路径

    if [ ! -f "$source" ]; then
        echo "    [!] Source not found: $source"
        return
    fi

    # 与 link_config 相同的备份逻辑
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        mv "$target" "$target$BACKUP_SUFFIX"
    fi

    ln -s "$source" "$target"
    echo "    Linked $target"
}

# ------------------------------------------------------------
# install_tui：部署终端（TUI）类软件配置
#   nvim  → ~/.config/nvim
#   tmux  → ~/.tmux.conf + ~/.tmux/plugins
#   zsh   → ~/.zshrc + ~/.config/zsh/secrets.zsh + ~/.config/zshrc.d/
# ------------------------------------------------------------
install_tui() {
    echo "== TUI Software Installer (nvim, tmux, zsh) =="
    echo

    # TUI: nvim —— 整目录链接
    link_config nvim

    # TUI: tmux —— 配置文件与插件目录分开处理
    echo "[*] Processing tmux"
    TMUX_SOURCE_CONF="$SCRIPT_DIR/tmux/.tmux.conf"      # 仓库里的 tmux 配置
    TMUX_TARGET_CONF="$HOME/.tmux.conf"                 # 用户根目录下的 tmux 配置
    TMUX_SOURCE_PLUGINS="$SCRIPT_DIR/tmux/plugins"      # 仓库里的插件（tpm/resurrect/continuum 等）
    TMUX_TARGET_PLUGINS="$HOME/.tmux/plugins"           # tpm 约定插件必须装在 ~/.tmux/plugins

    # tmux.conf 用 link_file 同样的备份逻辑（此处手动展开，
    # 因为目标在 $HOME 而不是 $CONFIG_DIR）
    if [ -f "$TMUX_SOURCE_CONF" ]; then
        if [ -L "$TMUX_TARGET_CONF" ]; then
            rm "$TMUX_TARGET_CONF"
        elif [ -f "$TMUX_TARGET_CONF" ]; then
            mv "$TMUX_TARGET_CONF" "$TMUX_TARGET_CONF$BACKUP_SUFFIX"
        fi
        ln -s "$TMUX_SOURCE_CONF" "$TMUX_TARGET_CONF"
        echo "    Linked tmux.conf"
    fi

    # 插件目录同样软链接（tpm 会要求 ~/.tmux/plugins 存在才能工作）
    if [ -d "$TMUX_SOURCE_PLUGINS" ]; then
        mkdir -p "$HOME/.tmux"
        if [ -L "$TMUX_TARGET_PLUGINS" ]; then
            rm "$TMUX_TARGET_PLUGINS"
        elif [ -d "$TMUX_TARGET_PLUGINS" ]; then
            mv "$TMUX_TARGET_PLUGINS" "$TMUX_TARGET_PLUGINS$BACKUP_SUFFIX"
        fi
        ln -s "$TMUX_SOURCE_PLUGINS" "$TMUX_TARGET_PLUGINS"
        echo "    Linked tmux plugins"
    fi
    echo

    # TUI: zsh —— 主配置 .zshrc 链接到用户根目录
    link_file "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # secrets.zsh：存放 API 密钥（DEEPSEEK_API_KEY 等）。
    # 仓库里只有模板（secrets.zsh.example），首次部署时从模板复制，
    # 且设为 600 权限（仅本人可读写），避免密钥泄露
    if [ ! -f "$HOME/.config/zsh/secrets.zsh" ]; then
        mkdir -p "$HOME/.config/zsh"
        cp "$SCRIPT_DIR/zsh/secrets.zsh.example" "$HOME/.config/zsh/secrets.zsh"
        chmod 600 "$HOME/.config/zsh/secrets.zsh"
        echo "    Created ~/.config/zsh/secrets.zsh - please fill in your API keys"
    fi

    # zshrc.d：附加的 zsh 片段脚本，直接复制（非链接，因为会被 zsh 顺序加载）
    if [ -d "$SCRIPT_DIR/zsh/zshrc.d" ]; then
        mkdir -p "$HOME/.config/zshrc.d"
        for f in "$SCRIPT_DIR/zsh/zshrc.d/"*; do
            [ -f "$f" ] && cp "$f" "$HOME/.config/zshrc.d/"
        done
        echo "    Installed zshrc.d scripts"
    fi
    echo

    # 安装完成的提示与手动步骤
    echo "== TUI install complete =="
    echo
    echo "Post-install:"
    echo "  tmux: tmux source ~/.tmux.conf"
    echo "  zsh:  重新打开终端或 exec zsh"
    echo
    echo "手动配置："
    echo "  Shell API 密钥 → cp zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh"
    echo "                  然后填入 DEEPSEEK_API_KEY、TAVILY_API_KEY 等"
    echo
}

# ------------------------------------------------------------
# install_gui：部署图形界面（GUI）类软件配置
#   hypr    → ~/.config/hypr（Hyprland 窗口管理器）
#   wayle   → ~/.config/wayle/config.toml（Wayland shell / 状态栏）
#   fuzzel  → ~/.config/fuzzel（应用启动器）
#   kitty   → ~/.config/kitty（终端模拟器）
#   fcitx5  → ~/.config/fcitx5 + 主题 + anytalk 密钥
#   gtk     → ~/.gtkrc-2.0 + ~/.config/gtk-* + Kvantum + mimeapps
#   qq      → ~/.config/qq-flags.conf（QQ Electron 启动参数，Wayland 输入法修复）
#   xdg-desktop-portal → ~/.config/xdg-desktop-portal/portals.conf（portal 后端路由）
#   xdg-desktop-portal-termfilechooser → ~/.config/xdg-desktop-portal-termfilechooser/config（终端文件选择器）
#   systemd → ~/.config/systemd/user/*.conf（用户级服务覆盖项）
#   wireplumber → 蓝牙音频 buffer 配置
# ------------------------------------------------------------
install_gui() {
    echo "== GUI Software Installer (hypr, wayle, fuzzel, kitty, fcitx5, gtk, systemd, wireplumber, qq, portal) =="
    echo

    # GUI: Hyprland —— 窗口管理器，配置较多，整目录链接
    link_config hypr

    # GUI: Wayle —— wayle 需要的是单个 config.toml 文件，
    # 先建好目录再链接文件
    echo "[*] Deploying wayle"
    mkdir -p "$CONFIG_DIR/wayle"
    link_file "$SCRIPT_DIR/wayle/config.toml" "$CONFIG_DIR/wayle/config.toml"
    echo

    # GUI: Fuzzel —— 应用启动器
    link_config fuzzel

    # GUI: Kitty —— 终端模拟器
    link_config kitty

    # GUI: Fcitx5 —— 输入法
    link_config fcitx5

    # GUI: Fcitx5 主题 —— 主题放 ~/.local/share/fcitx5/themes，
    # 逐个子主题分别链接到仓库对应目录
    echo "[*] Deploying fcitx5 themes"
    FCITX5_THEME_DIR="$HOME/.local/share/fcitx5/themes"
    FCITX5_THEME_SOURCE="$SCRIPT_DIR/fcitx5/themes"
    if [ -d "$FCITX5_THEME_SOURCE" ]; then
        mkdir -p "$FCITX5_THEME_DIR"
        # 遍历每个主题目录，链接过去（同样带备份逻辑）
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

    # GUI: Fcitx5 anytalk —— 火山引擎语音输入的密钥配置。
    # 只从模板复制，绝不覆盖已有文件（密钥不可用 git 管理）
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

    # GUI: GTK 主题 —— 涉及 gtk2/gtk3/gtk4/Kvantum/mimeapps，
    # 分别链接到各自的约定位置
    echo "[*] Deploying GTK theme configs"
    link_file "$SCRIPT_DIR/gtk/gtkrc-2.0" "$HOME/.gtkrc-2.0"
    link_file "$SCRIPT_DIR/gtk/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
    link_file "$SCRIPT_DIR/gtk/gtk-3.0/gtk.css" "$CONFIG_DIR/gtk-3.0/gtk.css"
    link_file "$SCRIPT_DIR/gtk/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0/settings.ini"
    link_file "$SCRIPT_DIR/gtk/Kvantum/kvantum.kvconfig" "$CONFIG_DIR/Kvantum/kvantum.kvconfig"
    link_file "$SCRIPT_DIR/gtk/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
    echo

    # GUI: QQ —— linuxqq 脚本读取 ~/.config/qq-flags.conf 作为 Electron 启动参数。
    # 当前用途是 --ozone-platform=wayland，让 QQ 走原生 Wayland（而非 XWayland），
    # 从而用 fcitx5 的 text-input-v3 原生输入法协议，规避 XIM 在快速打字时的丢键问题
    echo "[*] Deploying QQ flags"
    link_file "$SCRIPT_DIR/qq/qq-flags.conf" "$CONFIG_DIR/qq-flags.conf"
    echo

    # GUI: XDG Desktop Portal —— portals.conf 决定各 portal 接口走哪个后端。
    # 当前路由：ScreenCast/Screenshot/GlobalShortcuts→hyprland，
    # RemoteDesktop→hypr-kdeconnect（KDE Connect 远程输入桥接），
    # FileChooser→termfilechooser（终端文件选择器，yazi 替代 GTK 对话框）
    echo "[*] Deploying XDG Desktop Portal config"
    mkdir -p "$CONFIG_DIR/xdg-desktop-portal"
    link_file "$SCRIPT_DIR/xdg-desktop-portal/portals.conf" "$CONFIG_DIR/xdg-desktop-portal/portals.conf"
    echo

    # GUI: xdg-desktop-portal-termfilechooser —— 让应用的文件选择对话框
    # 改用终端文件管理器（本机 yazi）+ kitty 打开。配置文件放在
    # ~/.config/xdg-desktop-portal-termfilechooser/（应用指定的用户配置目录）
    echo "[*] Deploying termfilechooser config"
    mkdir -p "$CONFIG_DIR/xdg-desktop-portal-termfilechooser"
    link_file "$SCRIPT_DIR/xdg-desktop-portal-termfilechooser/config" "$CONFIG_DIR/xdg-desktop-portal-termfilechooser/config"
    echo

    # GUI: systemd 用户级覆盖项 —— 复制（非链接），
    # 因为 systemd 只认 ~/.config/systemd/user 下的普通文件；
    # 复制后用 daemon-reload 让改动立即生效
    echo "[*] Deploying systemd user overrides"
    SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
    SYSTEMD_SOURCE="$SCRIPT_DIR/systemd/user"
    if [ -d "$SYSTEMD_SOURCE" ]; then
        # find 找到每个 .conf 覆盖文件，复制到对应相对路径
        find "$SYSTEMD_SOURCE" -type f -name "*.conf" | while read -r f; do
            relative="${f#$SYSTEMD_SOURCE/}"
            target="$SYSTEMD_USER_DIR/$relative"
            mkdir -p "$(dirname "$target")"
            cp "$f" "$target"
            echo "    Copied $relative"
        done
        # 重载 systemd 用户实例，让新覆盖项生效；失败不阻断（如非登录会话）
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    echo

    # GUI: 截图脚本 —— 链接到 ~/.local/bin，方便 PATH 直接调用
    echo "[*] Deploying screenshot script"
    mkdir -p "$HOME/.local/bin"
    link_file "$SCRIPT_DIR/hypr/scripts/screenshot" "$HOME/.local/bin/screenshot"
    echo

    # GUI: WirePlumber 蓝牙音频 —— 解决蓝牙播放卡顿的 buffer 配置
    echo "[*] Deploying WirePlumber bluetooth config"
    WP_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
    WP_SOURCE="$SCRIPT_DIR/wireplumber/51-bluetooth-buffer.conf"
    if [ -f "$WP_SOURCE" ]; then
        mkdir -p "$WP_DIR"
        link_file "$WP_SOURCE" "$WP_DIR/51-bluetooth-buffer.conf"
    fi
    echo

    # 安装完成的提示与手动步骤
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
    echo
}

# ------------------------------------------------------------
# 入口分发：根据参数决定执行 TUI / GUI / 全部
#   ${1:-all}：参数为空时默认 all
# ------------------------------------------------------------
case "${1:-all}" in
    tui)
        install_tui
        ;;
    gui)
        install_gui
        ;;
    all)
        install_tui
        install_gui
        ;;
    -h|--help)
        usage
        ;;
    *)  # 未知参数：报错并显示用法
        echo "Unknown option: $1"
        usage
        ;;
esac

# 收尾总结：列出手动配置项（凭据类文件不放入仓库，需自行填写）
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

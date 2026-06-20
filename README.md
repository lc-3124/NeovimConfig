# lc3124's dotfiles

Arch Linux 配置管理项目。通过符号链接（symlink）统一管理桌面环境配置，支持一键部署。

## 目录

| 目录 | 说明 | 文档 |
|------|------|------|
| `nvim/` | Neovim 编辑器 (lazy.nvim) | [docs/neovim.md](docs/neovim.md) |
| `tmux/` | Tmux 终端复用器 (TPM) | [docs/tmux.md](docs/tmux.md) |
| `hypr/` | Hyprland 桌面环境 | — |
| `waybar/` | Waybar 状态栏配置 | — |
| `kitty/` | Kitty 终端模拟器 | — |
| `zsh/` | Zsh shell 配置 | — |
| `fcitx5/` | Fcitx5 输入法配置 + 豆包语音输入 | — |
| `fuzzel/` | Fuzzel 应用启动器 | — |
| `gtk/` | GTK/Qt 主题（adw-gtk3-dark, Kvantum）及 mimeapps | — |
| `coding/` | 代码格式化配置（clang-format, lua-ls） | — |
| `systemd/` | systemd 用户服务 | — |
| `docs/` | 文档 + 包列表 | 本目录 |

## 重装后恢复

```bash
# 安装官方包
sudo pacman -S --needed - < docs/pacman-native.txt

# 安装 AUR 包
yay -S --needed - < docs/aur-packages.txt

# 部署全部配置
./install.sh
```

## 主题

| 组件 | 主题 |
|------|------|
| Neovim | tokyonight (storm) |
| Tmux | tokyo-night-tmux |
| Hyprland | Catppuccin Frappe |
| Waybar | Catppuccin Frappe |
| GTK | adw-gtk3-dark |
| Qt | Kvantum MaterialAdw |
| Kitty | Nord |
| SDDM | Catppuccin Frappe |

## 要求

- Neovim ≥ 0.12
- Tmux ≥ 3.3
- Hyprland ≥ 0.40
- Fcitx5
- Nerd Font
- ripgrep、fd（Telescope 依赖）

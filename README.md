# lc3124's dotfiles

Neovim / Tmux / Hyprland / Waybar 配置管理。

## 目录

| 目录 | 说明 | 文档 |
|------|------|------|
| `nvim/` | Neovim 编辑器 (lazy.nvim) | [docs/neovim.md](docs/neovim.md) |
| `tmux/` | Tmux 终端复用器 (TPM) | [docs/tmux.md](docs/tmux.md) |
| `hypr/` | Hyprland 桌面环境 | — |
| `waybar/` | Waybar 状态栏配置 | — |
| `kitty/` | Kitty 终端模拟器 | — |
| `zsh/` | Zsh shell 配置 | — |
| `coding/` | 代码格式化配置 | — |
| `docs/` | 全局文档 | 本目录 |

## 安装

```bash
./install.sh
```

## 主题

| 组件 | 主题 |
|------|------|
| Neovim | tokyonight (storm) |
| Tmux | tokyo-night-tmux (night) |
| Hyprland | Catppuccin Frappe |
| Waybar | Catppuccin Frappe 风格 |
| Kitty | Nord 风格暗色 |

## 要求

- Neovim ≥ 0.12
- Tmux ≥ 3.3
- Hyprland ≥ 0.40
- Kitty / Ghostty
- Nerd Font（推荐 JetBrains Mono Nerd Font）
- ripgrep、fd（Telescope 依赖）

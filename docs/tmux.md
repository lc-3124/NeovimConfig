# Tmux 配置使用手册

## 目录结构

```
tmux/
├── .tmux.conf              # 主配置文件
├── install.sh              # 一键安装脚本
├── docs/tmux.md            # 本手册（详见项目根目录 docs/）
└── plugins/                # TPM 插件（预装）
    ├── tpm/                # Tmux Plugin Manager
    ├── tmux-sensible/      # 通用优化
    ├── tokyo-night-tmux/   # Tokyo Night 主题
    ├── tmux-resurrect/     # 会话保存/恢复
    └── tmux-continuum/     # 自动保存 + 恢复
```

---

## 快速安装

```bash
# 方式一：使用安装脚本
cd ~/config_mapping/NeovimConfig/tmux
./install.sh

# 方式二：手动
ln -sf ~/config_mapping/NeovimConfig/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/config_mapping/NeovimConfig/tmux/plugins ~/.tmux/plugins

# 重新加载
tmux source ~/.tmux.conf
```

---

## 基础操作

| 操作 | 快捷键 |
|---|---|
| 前缀键 | `Ctrl + b`（默认） |
| 水平分割 | `prefix + \` |
| 垂直分割 | `prefix + -` |
| 新建窗口 | `prefix + c` |
| 窗口选择器 | `prefix + "` |
| 最大化/恢复面板 | `prefix + z` |
| 上下左右切换面板 | `prefix + 方向键` |
| 同步所有面板输入 | `prefix + S`（再按一次关闭） |

### 面板大小调整

按住 `prefix` 不松，然后：

| 操作 | 快捷键 |
|---|---|
| 面板缩小 | `H` / `J` / `K` / `L`（对应左/下/上/右） |

（3 像素步进，可连续按）

### 面板交换

| 操作 | 快捷键 |
|---|---|
| 当前面板下移 | `prefix + {` |
| 当前面板上移 | `prefix + }` |

---

## 主题

使用 **Tokyo Night** 主题，配色与 Neovim 的 tokyonight 一致。

当前配置：`night` 风格（深色）。可在 `.tmux.conf` 中切换：

```conf
set -g @tokyo-night-tmux_theme night   # 当前
set -g @tokyo-night-tmux_theme storm   # 蓝灰调（对应 nvim tokyonight-storm）
set -g @tokyo-night-tmux_theme moon    # 暖灰
set -g @tokyo-night-tmux_theme day     # 浅色
```

**状态栏显示内容**（从左到右）：
- session 名称
- 窗口列表（编号 + 名称，当前窗口高亮）
- 已启用 widgets：
  - Git 分支/状态
  - 网络速度
  - 当前路径
  - 日期时间

---

## 会话持久化

两个插件配合工作：

### tmux-resurrect（手动保存/恢复）

| 操作 | 快捷键 |
|---|---|
| 保存当前所有会话 | `prefix + Ctrl + s` |
| 恢复上次保存 | `prefix + Ctrl + r` |

保存的内容：
- 所有 session、window、pane 及其布局
- 每个 pane 的工作目录
- pane 中运行的程序（仅预设白名单）
- nvim/vi 会话状态

### tmux-continuum（自动保存 + 恢复）

- **每 15 分钟**自动保存一次 tmux 环境
- **tmux 启动时自动恢复**最后保存的状态
- 与 tmux-resurrect 配合工作

---

## 注意事项

### 1. 真彩色支持

已在配置中启用 24bit 真彩色。如果终端模拟器不支持，状态栏颜色可能异常。推荐使用 kitty、alacritty、ghostty 或 WezTerm。

### 2. Tokyo Night 版本

确保插件更新到 v1.8+，否则 `show_path` 和 `show_netspeed` widget 可能不生效。更新方式：

```
prefix + U（TPM 更新所有插件）
```

### 3. tmux-resurrect 程序恢复

默认只恢复白名单中的程序：`vi vim nvim emacs man less more tail top htop irssi weechat mutt`。如需恢复其他程序（如 `ssh`、`docker`），编辑 `.tmux.conf` 添加：

```conf
set -g @resurrect-processes 'ssh docker-compose htop'
```

### 4. tmux-continuum 自动恢复

`@continuum-restore 'on'` 只在 **tmux 服务启动时**生效（比如开机或 `tmux new-session`）。
用 `tmux source ~/.tmux.conf` 重载配置不会触发自动恢复。

### 5. 配置文件重载

修改配置后执行：

```
tmux source ~/.tmux.conf
```

或在 tmux 中按 `prefix + r`。

### 6. 同步面板输入

`prefix + S` 可开启所有面板同步输入。适合同时对多台服务器执行相同命令。
再按一次 `prefix + S` 关闭。

---

## Git 分支指示器

状态栏中显示当前 Git 仓库的分支和状态：
- 分支名（如 `main`）
- `+n` 暂存的文件数
- `~n` 修改的文件数
- `-n` 删除的文件数
- `⇡`/`⇣` 远程同步指示

---

## 常见问题排查

### 状态栏显示异常

1. 确认终端支持真彩色
2. 运行 `tmux info | grep Tc` 显示 `Tc: (flag) true` 即正常
3. 确认 Tokyo Night 插件版本：检查 `~/.tmux/plugins/tokyo-night-tmux/tokyo-night.tmux`

### 自动恢复不生效

1. 确认已保存过环境（`prefix + Ctrl + s`）
2. 检查 `~/.local/share/tmux/resurrect/` 目录是否有 `.txt` 文件
3. 重启 tmux 服务：`tmux kill-server && tmux`

### 插件安装失败

```bash
# 手动安装
~/.tmux/plugins/tpm/bin/install_plugins
```

---

*最后更新: 2026-06-12*

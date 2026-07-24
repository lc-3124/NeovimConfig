# Hyprland 配置手册

## 概览

| 项目 | 内容 |
|------|------|
| 窗口管理器 | Hyprland |
| 终端 | Kitty |
| 状态栏 | Waybar |
| 启动器 | Fuzzel |
| 壁纸 | `awww`（静态）+ `mpvpaper`（视频） |
| 截图 | `grim` + `slurp` + `wl-copy` |
| 输入法 | Fcitx5 |
| 文件管理器 | Thunar |
| 配色 | Catppuccin（4 种风味） |

## 目录结构

```
hypr/
├── hyprland.conf         # 主配置文件
├── hyprpaper.conf        # 壁纸配置（awww）
├── scripts/
│   ├── cycle-wallpaper.sh  # 壁纸循环/模式切换
│   ├── screenshot          # 截图工具
│   └── VdpaperImport.sh    # 视频壁纸导入/转码
├── themes/
│   ├── frappe.conf
│   ├── latte.conf
│   ├── macchiato.conf
│   └── mocha.conf
├── resource/
│   ├── images/             # 静态壁纸图片
│   └── videos/             # 视频壁纸文件
└── README.md               # 本文件
```

## 配色主题

使用 Catppuccin 四风味，通过 `hyprland.conf` 第 27 行的 `source` 切换：

```conf
source = ~/.config/hypr/themes/frappe.conf
```

可用的主题文件：
- `frappe.conf` — 暖色调
- `latte.conf` — 亮色
- `macchiato.conf` — 柔和
- `mocha.conf` — 深色

主题文件只定义颜色变量，实际引用颜色的地方在 `hyprland.conf` 中直接使用 `$变量名`。

## 壁纸系统

### 静态壁纸

使用 `awww` 守护进程（`exec-once` 启动）。初始壁纸在启动后 1 秒设置。

### 视频壁纸

使用 `mpvpaper` 播放视频文件作为壁纸。

### cycle-wallpaper.sh

双模式静态/视频壁纸管理器。

```bash
# 切换到下一张壁纸（当前模式下）
~/.config/hypr/scripts/cycle-wallpaper.sh next

# 切换静态/视频模式
~/.config/hypr/scripts/cycle-wallpaper.sh toggle
```

快捷键：
- `Win+Z` — 切换到下一张壁纸
- `Win+X` — 切换静态/视频模式

状态文件存储在 `/tmp/`：
- `/tmp/hyprwall-mode` — 当前模式（static/dynamic）
- `/tmp/hyprwall-sindex` — 当前图片索引
- `/tmp/hyprwall-vindex` — 当前视频索引

### VdpaperImport.sh

将视频文件导入并转码为壁纸兼容格式。

```bash
./VdpaperImport.sh /path/to/video.mp4
```

转码参数：`scale=1280:-2, fps=15`, `libx264`, `crf=28`, 无音频。

## 截图

快捷键：
| 按键 | 功能 |
|------|------|
| `Print` | 区域截图 |
| `Shift+Print` | 全屏截图 |
| `Ctrl+Print` | 当前窗口截图 |

截图保存至 `~/Documents/Pictures/screenshot/`，并自动复制到剪贴板。

依赖：`grim`, `slurp`, `wl-clipboard`, `hyprctl`, `jq`

## 窗口规则

### Kitty 浮动模式

Kitty 终端以浮动窗口启动，默认大小 1650x880，居中，透明度 0.85。适合作为临时编辑器或参考窗口。

### Steam

Steam 窗口浮动居中。

### Waybar

Waybar 设置为浮动层（已 dock 化，适用于特殊布局）。

### suppress-maximize

全局规则：忽略所有窗口的最大化请求。窗口行为统一由 Hyprland 平铺管理。

### fix-xwayland-drag

修复 XWayland 应用在浮动模式下拖拽/焦点异常的问题（如 Wine 应用）。

## 光标缩放

| 快捷键 | 功能 |
|--------|------|
| `Win+Shift+P` | 放大光标（×1.1） |
| `Win+Shift+L` | 缩小光标（×0.9，最小 1.0） |

通过 `hyprctl` 动态调整 `cursor:zoom_factor`。

## 启动项

| 命令 | 用途 |
|------|------|
| `systemctl --user start xdg-desktop-portal-hyprland` | 屏幕共享/远程桌面 |
| `fcitx5 -d` | 输入法 |
| `waybar` | 状态栏 |
| `awww-daemon` | 壁纸守护进程 |
| `awww img ...` | 设置初始壁纸 |

## 环境变量

| 变量 | 值 |
|------|----|
| `QT_QPA_PLATFORMTHEME` | `qt5ct` |
| `XCURSOR_THEME` | `Bibata-Modern-Classic` |
| `XCURSOR_SIZE` | `24` |
| `HYPRCURSOR_THEME` | `Bibata-Modern-Classic` |
| `HYPRCURSOR_SIZE` | `24` |

## 键盘快捷键一览

### 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Win+Q` | 打开终端（Kitty） |
| `Win+C` | 关闭当前窗口 |
| `Win+M` | 退出 Hyprland |
| `Win+E` | 打开文件管理器（Thunar） |
| `Win+V` | 切换窗口浮动/平铺 |
| `Win+R` | 打开 Fuzzel 启动器 |
| `Win+P` | 切换 Dwindle 伪平铺 |
| `Win+←↑→↓` | 切换窗口焦点 |

### 工作区

| 快捷键 | 功能 |
|--------|------|
| `Win+1~0` | 切换到工作区 1~10 |
| `Win+Shift+1~0` | 移动窗口到工作区 1~10 |
| `Win+S` | 切换特殊工作区（草稿箱） |
| `Win+Shift+S` | 移动窗口到特殊工作区 |
| `Win+滚轮` | 循环切换工作区 |

### 媒体键

| 按键 | 功能 |
|------|------|
| `XF86AudioRaiseVolume` | 音量 +5% |
| `XF86AudioLowerVolume` | 音量 -5% |
| `XF86AudioMute` | 静音切换 |
| `XF86AudioMicMute` | 麦克风静音切换 |
| `XF86MonBrightnessUp` | 亮度 +5% |
| `XF86MonBrightnessDown` | 亮度 -5% |
| `XF86AudioNext` | 下一曲 |
| `XF86AudioPrev` | 上一曲 |
| `XF86AudioPlay/Pause` | 播放/暂停 |

### 特殊功能

| 快捷键 | 功能 |
|--------|------|
| `F2` | 语音输入（fcitx5-anytalk） |
| `Win+Shift+Q` | 语音输入（AnyTalk，焦点无关） |
| `Win+Z` | 下一张壁纸 |
| `Win+X` | 切换静态/视频壁纸 |
| `Win+Shift+P` | 放大光标 |
| `Win+Shift+L` | 缩小光标 |
| `Win+左键拖拽` | 移动窗口 |
| `Win+右键拖拽` | 调整窗口大小 |

## 依赖

### 运行时

- `hyprland` — 窗口管理器
- `kitty` — 终端
- `waybar` — 状态栏
- `fuzzel` — 应用启动器
- `awww` — 静态壁纸
- `mpvpaper` — 视频壁纸
- `fcitx5` — 输入法
- `thunar` — 文件管理器

### 截图

- `grim`, `slurp`, `wl-clipboard` — 截图工具链
- `hyprctl`, `jq` — 窗口信息获取

### 硬件控制

- `wpctl` (WirePlumber) — 音量控制
- `brightnessctl` — 亮度控制
- `playerctl` — 媒体播放控制

## 切换主题

编辑 `~/.config/hypr/hyprland.conf` 第 27 行的 `source`，将 `frappe` 改为 `latte`/`macchiato`/`mocha`，然后：

```bash
hyprctl reload
```

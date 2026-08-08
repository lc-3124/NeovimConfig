# Hyprland 配置手册

## 概览

| 项目 | 内容 |
|------|------|
| 窗口管理器 | Hyprland (>= 0.55, Lua 配置) |
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
├── hyprland.conf                  # 主入口（Lua，加载各模块）
├── hyprland.conf.hyprlang.bak     # 旧版 hyprlang 配置备份
├── .luarc.json                    # Lua LSP 配置（stubs 路径）
├── configure/
│   ├── env.lua                    # 环境变量 & 自启动
│   ├── looking&basics.lua         # 外观（general/decoration/动画/输入/布局）
│   ├── monitor.lua                # 显示器布局
│   ├── keybind.lua                # 快捷键绑定
│   └── typical.lua                # 应用程序窗口规则
├── scripts/
│   ├── cycle-wallpaper.sh         # 壁纸循环/模式切换
│   ├── screenshot                 # 截图工具
│   └── VdpaperImport.sh           # 视频壁纸导入/转码
├── themes/
│   ├── frappe.conf                # Catppuccin Frappe（旧版 hyprlang）
│   ├── frappe.lua                 # Catppuccin Frappe（Lua 版）
│   ├── latte.conf                 # 亮色
│   ├── macchiato.conf             # 柔和
│   └── mocha.conf                 # 深色
├── resource/
│   ├── images/                    # 静态壁纸图片
│   └── videos/                    # 视频壁纸文件
└── docs/
    └── hypr.md                    # 本文件
```

## 配置架构（Lua）

> Hyprland >= 0.55 已弃用 hyprlang，改用 Lua。旧配置备份在 `hyprland.conf.hyprlang.bak`。

主入口 `hyprland.conf` 按功能拆分为 5 个模块，通过 `dofile()` 加载：

| 文件 | 职责 |
|------|------|
| `configure/env.lua` | `env` 环境变量、`ecosystem` 权限、`hyprland.start` 自启动事件 |
| `configure/looking&basics.lua` | `general`/`decoration`/`animations`/`input`/`gestures`/布局/`misc`/`xwayland` |
| `configure/monitor.lua` | 显示器模式/位置/缩放 |
| `configure/keybind.lua` | 所有快捷键 (`hl.bind` / `hl.bindm`) |
| `configure/typical.lua` | 窗口规则 (`hl.window_rule`) — 应用专属设置 |

## 配色主题

使用 Catppuccin 四风味。通过加载不同主题文件切换配色：

```lua
-- hyprland.conf 或 configure/looking&basics.lua 中使用
local theme = dofile("themes/frappe.lua")
hl.config({
  general = {
    col.active_border = theme.mauve,
  },
})
```

可用的主题文件（旧版 hyprlang 格式保留兼容）：
- `frappe` — 暖色调（当前使用）
- `latte` — 亮色
- `macchiato` — 柔和
- `mocha` — 深色

Lua 版主题文件 (`themes/*.lua`) 导出 `0xAARRGGBB` 格式颜色值，可直接用于 `hl.config()`。

## 壁纸系统

### 静态壁纸

使用 `awww` 守护进程（`hl.on("hyprland.start")` 中启动，见 `configure/env.lua`）。初始壁纸在启动后 1 秒设置。

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

窗口规则集中在 `configure/typical.lua` 中，使用 `hl.window_rule()` 定义。

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

定义在 `configure/env.lua` 的 `hl.on("hyprland.start")` 事件中。

| 命令 | 用途 |
|------|------|
| `systemctl --user start xdg-desktop-portal-hyprland` | 屏幕共享/远程桌面 |
| `fcitx5 -d` | 输入法 |
| `systemctl --user start hyprpolkitagent` | polkit 认证代理 |
| `wayle` | 状态栏 |
| `awww-daemon` | 壁纸守护进程 |
| `awww img ...` | 设置初始壁纸 |

## 环境变量

| 变量 | 值 | 所在文件 |
|------|----|----------|
| `QT_QPA_PLATFORMTHEME` | `qt5ct` | `configure/env.lua` |
| `XCURSOR_THEME` | `Bibata-Modern-Classic` | `configure/env.lua` |
| `XCURSOR_SIZE` | `24` | `configure/env.lua` |
| `HYPRCURSOR_THEME` | `Bibata-Modern-Classic` | `configure/env.lua` |
| `HYPRCURSOR_SIZE` | `24` | `configure/env.lua` |

## 键盘快捷键一览

### 窗口管理

| 快捷键 | 功能 | 所在文件 |
|--------|------|----------|
| `Win+Q` | 打开终端（Kitty） | `configure/keybind.lua` |
| `Win+C` | 关闭当前窗口 | `configure/keybind.lua` |
| `Win+M` | 退出 Hyprland | `configure/keybind.lua` |
| `Win+E` | 打开文件管理器（Thunar） | `configure/keybind.lua` |
| `Win+V` | 切换窗口浮动/平铺 | `configure/keybind.lua` |
| `Win+R` | 打开 Fuzzel 启动器 | `configure/keybind.lua` |
| `Win+P` | 切换 Dwindle 伪平铺 | `configure/keybind.lua` |
| `Win+←↑→↓` | 切换窗口焦点 | `configure/keybind.lua` |

### 工作区

| 快捷键 | 功能 | 所在文件 |
|--------|------|----------|
| `Win+1~0` | 切换到工作区 1~10 | `configure/keybind.lua` |
| `Win+Shift+1~0` | 移动窗口到工作区 1~10 | `configure/keybind.lua` |
| `Win+S` | 切换特殊工作区（草稿箱） | `configure/keybind.lua` |
| `Win+Shift+S` | 移动窗口到特殊工作区 | `configure/keybind.lua` |
| `Win+滚轮` | 循环切换工作区 | `configure/keybind.lua` |

### 媒体键

| 按键 | 功能 | 所在文件 |
|------|------|----------|
| `XF86AudioRaiseVolume` | 音量 +5% | `configure/keybind.lua` |
| `XF86AudioLowerVolume` | 音量 -5% | `configure/keybind.lua` |
| `XF86AudioMute` | 静音切换 | `configure/keybind.lua` |
| `XF86AudioMicMute` | 麦克风静音切换 | `configure/keybind.lua` |
| `XF86MonBrightnessUp` | 亮度 +5% | `configure/keybind.lua` |
| `XF86MonBrightnessDown` | 亮度 -5% | `configure/keybind.lua` |
| `XF86AudioNext` | 下一曲 | `configure/keybind.lua` |
| `XF86AudioPrev` | 上一曲 | `configure/keybind.lua` |
| `XF86AudioPlay/Pause` | 播放/暂停 | `configure/keybind.lua` |

### 特殊功能

| 快捷键 | 功能 | 所在文件 |
|--------|------|----------|
| `F2` | 语音输入（fcitx5-anytalk） | `configure/keybind.lua` |
| `Win+Shift+Q` | 语音输入（AnyTalk，焦点无关） | `configure/keybind.lua` |
| `Win+Z` | 下一张壁纸 | `configure/keybind.lua` |
| `Win+X` | 切换静态/视频壁纸 | `configure/keybind.lua` |
| `Win+Shift+P` | 放大光标 | `configure/keybind.lua` |
| `Win+Shift+L` | 缩小光标 | `configure/keybind.lua` |
| `Win+左键拖拽` | 移动窗口 | `configure/keybind.lua` |
| `Win+右键拖拽` | 调整窗口大小 | `configure/keybind.lua` |

## 依赖

### 运行时

- `hyprland` — 窗口管理器
- `kitty` — 终端
- `wayle` — 状态栏
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

### 方式一：Lua 版

```lua
-- 在 configure/looking&basics.lua 中：
local theme = dofile("themes/mocha.lua")  -- 改为想要的风格
```

### 方式二：旧版 hyprlang（兼容）

如需使用旧版 `.conf` 主题文件，修改 `hyprland.conf.hyprlang.bak` 中的 `source` 行。

切换后执行：

```bash
hyprctl reload
```

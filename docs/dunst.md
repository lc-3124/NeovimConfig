# Dunst — 通知守护进程

## 目录结构

```
~/.config/dunst/                   -> ~/NeovimConfig/dunst/
└── dunstrc                         通知配置
```

## 快捷键

| 按键 | 行为 |
|------|------|
| 左键点击 | 关闭当前通知 |
| 中键点击 | 触发默认操作 |
| 右键点击 | 关闭全部通知 |
| `notify-send "标题" "内容"` | 发普通通知 |
| `notify-send -u critical "标题" "内容"` | 发紧急通知 |
| `notify-send -u low "标题" "内容"` | 发低优通知 |
| `dunstctl history-pop` | 恢复最近关闭的通知 |
| `dunstctl close-all` | 关闭全部 |
| `dunstctl context` | 打开上下文菜单 |

## 配色

基于 Catppuccin Frappé（`hypr/themes/frappe.conf`）：

| 级别 | 背景 | 前景 | 边框 | 超时 |
|------|------|------|------|------|
| low | `#303446` | `#a5adce` | `#626880` | 5s |
| normal | `#303446` | `#c6d0f5` | `#babbf1` | 8s |
| critical | `#303446` | `#c6d0f5` | `#e78284` | 不限 |

## 窗口透明效果

在 `hypr/hyprland.conf` 中通过 windowrule 管理透明度：

```
windowrule {
    name = dunst-blur
    match:class = ^(dunst)$
    opacity = 0.85
}
```

由 Hyprland 合成器处理，非 dunst 自身设置。调整透明度编辑 `hypr/hyprland.conf` 中的 `opacity` 值。

## 依赖

- `dunst` — 通知守护进程本身

## 重载配置

```bash
killall dunst && dunst &
```

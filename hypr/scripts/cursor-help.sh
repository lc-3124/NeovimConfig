#!/bin/sh
# 光标模式操作手册（fuzzel 弹出）
fuzzel --dmenu --prompt="光标模式: " --lines=24 --width=66 -f "monospace:size=10" <<'EOF'
 ── 光标模式（纯键盘控鼠）──
 META + ;       进入光标模式（指针移到当前屏中心）
 META + :       网格选点（hyprwarp）→ 选点后进入光标模式
 ── 光标模式内 ──
 w a s d        移动指针（按住持续；可同时按两个 → 斜向）
 i              按住 = 缓速，松开 = 快速
 j              左键单击
 o              右键单击
 空格           中键单击
 v              按住左键（拖拽 / 选择）
 q  /  e        向上 / 向下滚动（按住持续）
 SUPER + ;      重新居中进入
 SUPER + :      再次网格选点
 ESC            退出（自动隐藏并禁用物理鼠标）
 META + ALT + ; 显示本手册
 ── 其他 ──
 META + SHIFT + X   开关物理鼠标（隐藏禁用 / 恢复）
 META + SHIFT + Esc 紧急恢复（杀 hyprwarp + 退出子图）
EOF

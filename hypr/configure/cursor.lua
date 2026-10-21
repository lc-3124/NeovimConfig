-- ============================================================================
-- cursor 子图：hyprwarp 网格选点后进入
--
-- 实际功能由常驻守护 /usr/local/bin/hypr-cursor 完成：
--   直接读 evdev 键盘 → 自己维护按下状态 → 用 dispatch movecursor 设置绝对位置。
--   这样不依赖 Hyprland 的 release 绑定（实测 submap 内会丢），也不会每次按键
--   spawn 一个 shell 进程。
--
-- 这里的 bind 只负责「消费按键」，避免 w/a/s/d/j/o/q/e/i 等落到底下的窗口。
-- 源码：hypr/cursor-daemon/hypr-cursor.cpp
-- ============================================================================

hl.define_submap("cursor", function()
  -- 只消费，不执行任何动作（真正的处理在 hypr-cursor 守护里）
  local function consume() end
  for _, key in ipairs({ "w", "a", "s", "d", "i", "j", "o", "space", "v", "q", "e" }) do
    hl.bind(key, consume)
  end

  hl.bind("META + ALT + semicolon", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-help.sh"))
  hl.bind("META + SHIFT + escape", hl.dsp.exec_cmd("pkill -x hyprwarp 2>/dev/null; rm -f ${XDG_RUNTIME_DIR:-/tmp}/hypr-cursor-active; hyprctl dispatch 'hl.dsp.submap(\"reset\")'"))
  hl.bind("SUPER + semicolon", hl.dsp.exec_cmd(
    "hyprctl eval 'hl.config({ cursor = { inactive_timeout = 3, hide_on_key_press = true }})'; hyprctl dispatch 'hl.dsp.submap(\"reset\")'; hyprctl dismissnotify; ~/.config/hypr/scripts/cursor-enter.sh"), { repeating = true })
  hl.bind("SUPER + SHIFT + semicolon", hl.dsp.exec_cmd(
    "hyprctl eval 'hl.config({ cursor = { inactive_timeout = 3, hide_on_key_press = true }})'; hyprctl dispatch 'hl.dsp.submap(\"reset\")'; hyprctl dismissnotify; ~/.config/hypr/scripts/hyprwarp-once.sh"), { repeating = true })
  hl.bind("escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-exit.sh"))
end)

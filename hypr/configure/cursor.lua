-- ============================================================================
-- cursor 子图：hyprwarp 网格选点后进入
--   移动：cursor-mv.sh 写方向 → 守护 cursor-mover.sh 连续输出
--   点击/滚动：直接 | dotoolc
-- ============================================================================

hl.define_submap("cursor", function()
  local MV = "~/.config/hypr/scripts/cursor-mv.sh"
  local MOVE = "~/.config/hypr/scripts/cursor-move.sh"
  local RELEASE = "~/.config/hypr/scripts/cursor-release.sh"
  -- press 记录方向，release 只移除该方向（支持多方向叠加成斜向）
  local function mvkey(keys, dir)
    hl.bind(keys, hl.dsp.exec_cmd(MOVE .. " " .. dir))
    hl.bind(keys, hl.dsp.exec_cmd(RELEASE .. " " .. dir), { release = true })
  end
  mvkey("h", "left"); mvkey("j", "down"); mvkey("k", "up"); mvkey("l", "right")
  -- SHIFT 切换快/慢速（静默）
  hl.bind("s", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-speed.sh"))
  hl.bind("v", hl.dsp.exec_cmd("echo \"buttondown left\" | dotoolc"))
  hl.bind("space", hl.dsp.exec_cmd("echo \"click left\" | dotoolc"))
  hl.bind("q",     hl.dsp.exec_cmd("echo \"click left\" | dotoolc"))
  hl.bind("w",     hl.dsp.exec_cmd("echo \"click middle\" | dotoolc"))
  hl.bind("e",     hl.dsp.exec_cmd("echo \"click right\" | dotoolc"))
  hl.bind("bracketleft",  hl.dsp.exec_cmd("echo \"wheel 20\" | dotoolc"),  { repeating = true })
  hl.bind("bracketright", hl.dsp.exec_cmd("echo \"wheel -20\" | dotoolc"), { repeating = true })
  hl.bind("META + ALT + semicolon", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-help.sh"))
  hl.bind("META + SHIFT + escape", hl.dsp.exec_cmd("pkill -x hyprwarp 2>/dev/null; hyprctl dispatch 'hl.dsp.submap(\"reset\")'"))
  hl.bind("SUPER + semicolon", hl.dsp.exec_cmd(
    MV .. " stop; echo \"buttonup left\" | dotoolc; hyprctl eval 'hl.config({ cursor = { inactive_timeout = 3, hide_on_key_press = true }})'; hyprctl dispatch 'hl.dsp.submap(\"reset\")'; hyprctl dismissnotify; ~/.config/hypr/scripts/cursor-enter.sh"), { repeating = true })
  hl.bind("SUPER + SHIFT + semicolon", hl.dsp.exec_cmd(
    MV .. " stop; echo \"buttonup left\" | dotoolc; hyprctl eval 'hl.config({ cursor = { inactive_timeout = 3, hide_on_key_press = true }})'; hyprctl dispatch 'hl.dsp.submap(\"reset\")'; hyprctl dismissnotify; ~/.config/hypr/scripts/hyprwarp-once.sh"), { repeating = true })
  hl.bind("escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-exit.sh"))
end)

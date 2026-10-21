-- ============================================================================
-- Hyprland 主配置入口 (Lua)
-- ============================================================================

require("configure.env")
require("configure.looking&basics")
require("configure.monitor")
require("configure.workspaces")
require("configure.permissions")
require("configure.keybind")
require("configure.typical")

-- ============================================================================
-- HyprVim：只用来做 WhichKey（按键提示浮层）；不启用它的 Vim 模式。
--   activate 指向一个几乎不会按到的键（PAUSE），彻底避免误入 NORMAL/INSERT。
--   SUPER+SPACE  → 显示「根（全局）快捷键」提示；再按一次或 ESC 关闭。
--   进入子图（如 screen / screen-move）时也会自动弹出对应提示。
-- ============================================================================
local HV = require("lua.plugins.hyprvim").setup({
  keys = { leader = "SUPER", activate = "PAUSE", exit = "ESCAPE" },
  which_key = {
    enabled = true,
    frontend = "quickshell",
    delay_ms = 0,
    position = "center",
    auto_show = { disabled = { "cursor" } },   -- cursor 子图不弹 WhichKey HUD
  },
})

hl.bind("SUPER + SPACE", function()
  HV.whichkey.toggle()
end, { description = "快捷键提示" })

-- 浮层显示期间截获 ESC：关闭浮层且不传给应用；
-- 浮层未显示时，正常把 ESC 转发给当前窗口（等价于原生行为）。
hl.unbind("ESCAPE")

-- screen / screen-move 子图：在全局 unbind 之后定义，保留子图内的 ESC 退出
local function monitor_neighbor(step)
  local ms = hl.get_monitors()
  table.sort(ms, function(a, b) return a.x < b.x end)
  local active = hl.get_active_monitor()
  local idx
  for i, m in ipairs(ms) do
    if active and m.name == active.name then idx = i end
  end
  if not idx then return nil end
  local t = idx + step
  if t < 1 or t > #ms then return nil end
  return ms[t].name
end

local function jump_monitor(step, carry_window)
  return function()
    local t = monitor_neighbor(step)
    if t then
      if carry_window then
        local tm = hl.get_monitor(t)
        local ws = tm and tm.active_workspace
        if ws then hl.dispatch(hl.dsp.window.move({ workspace = ws.id })) end
      end
      hl.dispatch(hl.dsp.focus({ monitor = t }))
    end
    hl.dispatch(hl.dsp.submap("reset"))
  end
end

hl.define_submap("screen", "reset", function()
  hl.bind("left",   jump_monitor(-1, false), { description = "焦点移到左屏" })
  hl.bind("right",  jump_monitor(1, false),  { description = "焦点移到右屏" })
  hl.bind("h",      jump_monitor(-1, false), { description = "焦点移到左屏" })
  hl.bind("l",      jump_monitor(1, false),  { description = "焦点移到右屏" })
  hl.bind("escape", function() end,          { description = "退出" })
end)

hl.define_submap("screen-move", "reset", function()
  hl.bind("left",   jump_monitor(-1, true), { description = "把窗口带到左屏" })
  hl.bind("right",  jump_monitor(1, true),  { description = "把窗口带到右屏" })
  hl.bind("h",      jump_monitor(-1, true), { description = "把窗口带到左屏" })
  hl.bind("l",      jump_monitor(1, true),  { description = "把窗口带到右屏" })
  hl.bind("escape", function() end,         { description = "退出" })
end)

hl.bind("ESCAPE", function()
  -- 1) 截图选区 (slurp) 进行中：ESC 取消截图。
  --    因为 ESC 被这个全局绑定拦截，slurp 作为 layer surface 收不到 ESC，
  --    所以在这里主动结束 slurp（slurp 退出后截图脚本的 region 分支会静默退出）。
  local p = io.popen("pgrep -x slurp 2>/dev/null")
  if p then
    local out = p:read("*a") or ""
    p:close()
    if out ~= "" then
      os.execute("pkill -x slurp 2>/dev/null")
      return
    end
  end

  -- 2) whichkey 浮层可见：关闭浮层且不传给应用
  local vis = require("hyprvim.config").state_dir .. "/whichkey-visible"
  local f = io.open(vis, "r")
  if f then
    f:close()
    HV.whichkey.close()
  else
    -- 3) 其它情况：把 ESC 转发给当前窗口（等价原生行为）
    hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "Escape", window = "activewindow" }))
  end
end)

-- cursor 子图：hyprwarp 选点后进入
--   移动：脚本 cursor-mv.sh 写方向 → 独立守护 cursor-mover.sh 连续输出
--   点击/滚动：恢复成之前可用的写法（直接 | dotoolc）
hl.define_submap("cursor", function()
  local MV = "~/.config/hypr/scripts/cursor-mv.sh"
  local MOVE = "~/.config/hypr/scripts/cursor-move.sh"
  local function mvkey(keys, dir)
    hl.bind(keys, hl.dsp.exec_cmd(MOVE .. " " .. dir))
    hl.bind(keys, hl.dsp.exec_cmd(MV .. " stop"), { release = true })
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

-- WhichKey HUD 毛玻璃：半透明背景 + 背景模糊
hl.layer_rule({
  name = "hyprvim-whichkey",
  match = { namespace = "hyprvim-whichkey" },
  blur = true,
  ignore_alpha = 0.3,
  no_anim = true,
})

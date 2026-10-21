-- ============================================================================
-- screen / screen-move 子图：跨屏移动焦点 / 把窗口带到另一块屏
--   在全局 ESC unbind 之后定义，保留子图内的 ESC 退出。
-- ============================================================================

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

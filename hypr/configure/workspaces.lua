-- ============================================================================
-- 工作区归属模块
-- ============================================================================
-- 两块屏各自独占一套 10 个工作区，互不串门：
--   内置屏 eDP-1    → 工作区 1–10
--   外接屏 HDMI-A-1 → 工作区 11–20
-- persistent = true：空置时也保留，便于 wayle 常显 10 个切换位。
-- 判定“当前屏”的键位逻辑见 keybind.lua（SUPER+1..0 按聚焦屏映射）。
-- ============================================================================

local BINDINGS = {
  { first = 1,  last = 10, monitor = "eDP-1" },
  { first = 11, last = 20, monitor = "HDMI-A-1" },
}

for _, group in ipairs(BINDINGS) do
  for i = group.first, group.last do
    hl.workspace_rule({
      workspace = tostring(i),
      monitor = group.monitor,
      persistent = true,
    })
  end
end

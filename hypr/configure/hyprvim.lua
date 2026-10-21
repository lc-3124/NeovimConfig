-- ============================================================================
-- HyprVim：仅用于 WhichKey（快捷键提示浮层），不启用它的 Vim 模式。
--   activate 指向几乎不会按到的键（PAUSE），彻底避免误入 NORMAL/INSERT。
--   SUPER+SPACE → 显示「根（全局）快捷键」提示；再按一次或 ESC 关闭。
--   进入子图（如 screen / screen-move）时也会自动弹出对应提示。
--
-- 与主配置的边界：hyprland.lua 只 require 本文件并从返回值拿 toggle/close/visible，
-- 不再直接出现 hyprvim 的 setup / 键绑定 / layer_rule。
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

-- WhichKey HUD 毛玻璃：半透明背景 + 背景模糊
hl.layer_rule({
  name = "hyprvim-whichkey",
  match = { namespace = "hyprvim-whichkey" },
  blur = true,
  ignore_alpha = 0.3,
  no_anim = true,
})

-- 对外接口（供主配置的 ESC 全局策略使用）
local M = {}

function M.toggle() HV.whichkey.toggle() end
function M.close()  HV.whichkey.close()  end

-- 浮层是否可见（插件通过状态文件记录）
function M.visible()
  local f = io.open(require("hyprvim.config").state_dir .. "/whichkey-visible", "r")
  if f then
    f:close()
    return true
  end
  return false
end

return M

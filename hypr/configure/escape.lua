-- ============================================================================
-- 全局 ESC 策略
--   1) 截图选区（slurp）进行中 → 取消截图
--   2) WhichKey 浮层可见 → 关闭浮层，不传给应用
--   3) 其它情况 → 把 ESC 转发给当前窗口（等价原生行为）
--
-- 必须先 unbind 原生 ESC，否则上面的逻辑不会生效。
-- ============================================================================

local HK = require("configure.hyprvim")

hl.unbind("ESCAPE")

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
  if HK.visible() then
    HK.close()
  else
    -- 3) 其它情况：把 ESC 转发给当前窗口（等价原生行为）
    hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "Escape", window = "activewindow" }))
  end
end)

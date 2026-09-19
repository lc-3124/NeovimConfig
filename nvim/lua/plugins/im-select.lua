-- ============================================================================
-- 插件：im-select.nvim（输入法切换联动）
-- 作用：离开插入模式时自动切回英文输入法，进入插入模式时恢复上次的中文输入法。
-- 适合中文用户，避免在普通模式/命令行下输入法弹中文。
-- 依赖系统侧有 im-select 程序（如 fcitx5 的 fcitx5-remote）。
-- ============================================================================
return {
  "keaising/im-select.nvim",
  event = "VeryLazy",   -- 启动后期加载
  config = function()
    require("im_select").setup({
      default_im_select = "keyboard-us",  -- 默认（普通模式）用的英文输入法标识
      -- 事件映射：
      -- 离开插入/命令行模式 → 切回英文
      set_default_events = { "InsertLeave", "CmdlineLeave" },
      -- 进入插入模式 → 恢复上次的输入法
      set_previous_events = { "InsertEnter" },
    })
  end,
}

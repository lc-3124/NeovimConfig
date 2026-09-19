-- ============================================================================
-- 插件：lualine.nvim（状态栏）
-- 作用：底部状态栏，显示模式、文件名、Git 分支、LSP 状态、行号/列号等。
-- ============================================================================
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },  -- 文件类型图标
  config = function()
    require("lualine").setup({
      options = {
        theme = "tokyonight",   -- 状态栏配色跟随 Tokyo Night
        globalstatus = true,    -- 使用全局单条状态栏（跨窗口共享，结合 laststatus=3）
        -- 组件分隔符（模块之间的分隔线）
        component_separators = { left = "", right = "" },
        -- 分区分隔符（大区之间的粗分隔线）
        section_separators = { left = "", right = "" },
      },
    })
  end,
}

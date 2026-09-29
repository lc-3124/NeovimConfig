-- ============================================================================
-- 插件：nvim-scrollbar（滚动条）
-- 作用：在窗口右侧显示滚动条，并标记诊断 / 搜索命中 / Git 改动 / 光标位置。
-- 默认已启用 cursor / diagnostic / handle；这里额外启用 gitsigns 标记，
-- 并在默认排除列表基础上追加侧栏与特殊缓冲，避免它们也长出滚动条。
-- 依赖：gitsigns.nvim（已装，用于 Git 标记）；纯 Lua，无强制依赖。
-- ============================================================================
return {
  "petertriho/nvim-scrollbar",
  lazy = false,   -- 启动即加载
  config = function()
    require("scrollbar").setup({
      handlers = {
        gitsigns = true,   -- 显示 Git 改动标记（依赖 nvim-gitsigns）
      },
    })
    -- 在默认排除列表之上追加：这些缓冲不显示滚动条
    local conf = require("scrollbar.config").get()
    vim.list_extend(conf.excluded_filetypes, {
      "NvimTree",     -- 文件树
      "sagaoutline",  -- lspsaga 符号大纲
      "Avante",       -- avante AI 对话窗
      "Trouble",
    })
  end,
}

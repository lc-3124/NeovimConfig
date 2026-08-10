-- ============================================================================
-- 插件：telescope.nvim（模糊查找器）
-- 作用：强大的文件/符号/内容搜索界面（fuzzy finder），用于快速跳转。
-- 搭配 fzf-native 原生扩展，搜索速度更快。
-- ============================================================================
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",  -- 通用工具库
    {
      "nvim-telescope/telescope-fzf-native.nvim",  -- fzf 算法原生实现
      build = "make",         -- 安装时编译 C 扩展
    },
  },
  config = function()
    local builtin = require("telescope.builtin")
    require("telescope").setup({
      extensions = { fzf = {} },  -- 启用 fzf 扩展
    })
    require("telescope").load_extension("fzf")

    -- \ff 搜索文件  \fg 全文搜索  \fb 切换 buffer  \fh 搜索帮助  \fs 文档符号
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Telescope document symbols" })
  end,
}

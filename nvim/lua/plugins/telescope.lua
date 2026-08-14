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
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "搜索文件" }) -- 按文件名模糊查找
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "全文搜索" }) -- 在文件内容里搜索关键字
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "切换缓冲区" }) -- 在已打开的文件间切换
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "搜索帮助" }) -- 搜索 nvim 帮助文档
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "文档符号" }) -- 当前文件的符号大纲
  end,
}

-- ============================================================================
-- 插件：trouble.nvim（诊断/符号/引用列表）
-- 作用：把 LSP 诊断、文档符号、引用等以可跳转的列表形式展示在侧边栏。
-- ============================================================================
return {
  "folke/trouble.nvim",
  cmd = "Trouble",   -- 按需加载（执行 :Trouble 时才加载）
  opts = {
    auto_close = true,     -- 关闭列表时自动隐藏窗口
    auto_jump = false,     -- 不自动跳到第一个条目
    focus = false,         -- 打开列表不抢焦点
    follow = true,         -- 列表跟随当前光标位置
    indent_guides = true,  -- 显示缩进引导线
    -- 列表图标
    icons = {
      indent = {
        top = "│ ",
        middle = "├╴",
        last = "└╴",
        fold_open = " ",
        fold_closed = " ",
        ws = "  ",
      },
      folder_closed = " ",
      folder_open = " ",
    },
    modes = {
      -- 预览模式：右侧显示诊断（scratch 缓冲，不影响当前编辑）
      preview = {
        mode = "diagnostics",
        preview = { type = "main", scratch = true },
      },
    },
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "诊断列表" },                   -- 全部诊断
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "当前文件诊断" },  -- 仅当前文件
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "文档符号" },           -- 符号大纲
    { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP 引用/定义" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },                  -- location 列表
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },                   -- quickfix 列表
  },
}

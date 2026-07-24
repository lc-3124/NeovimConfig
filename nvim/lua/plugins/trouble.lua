return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    auto_close = true,
    auto_jump = false,
    focus = false,
    follow = true,
    indent_guides = true,
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
      preview = {
        mode = "diagnostics",
        preview = { type = "main", scratch = true },
      },
    },
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "诊断列表" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "当前文件诊断" },
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "文档符号" },
    { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP 引用/定义" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
  },
}

return {
  "akinsho/bufferline.nvim",
  lazy = false,
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.opt.termguicolors = true  -- 必需：启用真彩色支持

    require("bufferline").setup({
      options = {
        mode = "buffers",
        -- diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "Good job, lc3124!", text_align = "left" }
        },
      },
      highlights = {
        -- 未选中缓冲区（保持与主题一致）
        buffer_visible = {
          fg = "#cdd6f4",  -- 文字颜色（浅色）
          bg = "#313244",  -- 背景色（深灰）
        },
        -- 选中缓冲区（仅加粗，不反色）
        buffer_selected = {
          fg = "#cdd6f4",  -- 文字颜色不变
          bg = "#313244",  -- 背景色不变
          bold = false,     -- 唯一强调：加粗
          italic = false,
          underline = false,
        },
        -- 背景填充区域
        fill = {
          bg = "#1e1e2e",  -- 匹配NeoDark主题背景
        },
        -- 分隔线颜色
        separator = {
          fg = "#45475a",  -- 中灰色分隔线
          bg = "#1e1e2e",
        },
      }
    })

    -- 快捷键绑定（保持原有）
    vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "下一个缓冲区" })
    vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "上一个缓冲区" })
  end
}

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.opt.termguicolors = true  -- 必需：启用真彩色支持

    require("bufferline").setup({
      options = {
        mode = "buffers",
        --separator_style = "slant",
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "文件树", text_align = "left" }
        },
        -- 其他基础配置...
      },
      -- 关键修改：高亮组自定义（移除反色，改用粗体）
      highlights = {
        -- 常规缓冲区样式（未选中状态）
        buffer_visible = {
          fg = "#1e1e2e",  -- 原背景色改为前景色（文字颜色）
          bg = "#cdd6f4",  -- 原前景色改为背景色
        },
        -- 选中缓冲区样式
        buffer_selected = {
          fg = "#1e1e2e",  -- 反转后的前景色
          bg = "#ffffff",  -- 反转后的背景色
          bold = true,     -- 可选：加粗选中标签
        },
        -- 其他高亮组（如分隔符、填充区域等）
        fill = {
          bg = "#1e1e2e",  -- 背景填充色（非标签区域）
        },
      buffer_selected = { 
        bold = true,            -- 聚焦时显示粗体
        italic = false,         -- 禁用斜体（避免冲突）
        underline = false,      -- 禁用下划线
        undercurl = false,      -- 禁用曲线下划线
      },
      -- 其他高亮组（保持默认或自定义）
      fill = { bg = "#1e1e2e" },
      separator = { fg = "#45475a" },
      buffer_visible = { fg = "#cdd6f4", bg = "#313244" },  -- 未聚焦缓冲区样式
    }
  })

  -- 快捷键绑定（可选）
  vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "下一个缓冲区" })
  vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "上一个缓冲区" })
end
}

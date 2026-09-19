-- ============================================================================
-- 插件：bufferline.nvim（缓冲区标签栏）
-- 作用：在窗口顶部把已打开的 buffer（文件）显示成一行标签，
-- 类似浏览器标签页，可点击/快捷键切换。
-- ============================================================================
return {
  "akinsho/bufferline.nvim",
  version = "*",                                -- 跟随稳定版本
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- 图标
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",   -- 显示模式：所有 buffer（也可选 tabs）
        -- 在文件树（NvimTree）打开时，标签栏左侧空出 offset，显示 "Explorer"
        offsets = {
          { filetype = "NvimTree", text = "Explorer", text_align = "left" },
        },
      },
    })
    -- Tab 键循环切换标签
    vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "下一个缓冲区" })
    vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "上一个缓冲区" })
  end,
}

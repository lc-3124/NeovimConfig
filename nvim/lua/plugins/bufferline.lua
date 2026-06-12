return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        offsets = {
          { filetype = "NvimTree", text = "Explorer", text_align = "left" },
        },
      },
    })
    vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "下一个缓冲区" })
    vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "上一个缓冲区" })
  end,
}

return {
  "utilyre/barbecue.nvim",
  event = "BufRead",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-navic").setup({
      lsp = { emmylua_ls = false },
    })
    require("barbecue").setup({
      theme = "auto",
      symbols = { separator = "" },
      show_modified = true,
    })
  end,
}

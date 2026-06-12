return {
  {
    "FotiadisM/tabset.nvim",
    event = "BufRead",
    opts = {
      defaults = {
        tabwidth = 2,
        expandtab = true,
      },
      languages = {
        python = { tabwidth = 4 },
        c = { tabwidth = 4 },
        cpp = { tabwidth = 4 },
        lua = { tabwidth = 2 },
        markdown = { tabwidth = 2 },
        json = { tabwidth = 2 },
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}

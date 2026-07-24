return {
  "windwp/nvim-ts-autotag",
  dependencies = "nvim-treesitter/nvim-treesitter",
  event = "InsertEnter",
  opts = {
    filetypes = { "html", "xml", "php", "javascript", "typescript", "markdown" },
  },
}

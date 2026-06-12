return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<F3>", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
  },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    require("nvim-tree").setup({
      sort = { sorter = "case_sensitive" },
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        indent_width = 2,
        group_empty = true,
        icons = {
          git_placement = "before",
          show = { file = true, folder = true, git = true },
        },
      },
      filesystem_watchers = {
        enable = false,
      },
      git = { enable = true },
      actions = {
        open_file = { quit_on_open = false },
      },
    })
  end,
}

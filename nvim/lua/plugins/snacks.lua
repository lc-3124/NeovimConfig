return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    animate = { enabled = true },
    scroll = { enabled = true },
    input = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
    scope = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
                                             
      ████ ██████           █████      ████
      ███████████             █████  
      █████████ ███████████████████████
     █████████  ███    ████████████
    █████████ █████████████████████████
   ██████████ ███    █████████████
   ███████████  ████████  ████████
    ██████████    ██████   ███████
      █████ ███      ████   █████
        ██    █        ██    ██
]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    dim = { enabled = true },
  },
  keys = {
    { "<leader>dd", function() Snacks.dashboard() end, desc = "Dashboard" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "删除缓冲区" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "关闭通知" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "通知历史" },
  },
}

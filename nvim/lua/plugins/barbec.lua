-- lua/plugins/barbecue.lua
return {
  {
    "utilyre/barbecue.nvim",
    event = "BufRead",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("barbecue").setup({
        theme = "auto",  -- 自动适配当前主题（包括 NeoDark）
        symbols = {
          separator = "",  -- 更美观的分隔符
        },
        show_modified = true,  -- 显示文件修改状态
        -- 自定义 NeoDark 配色（可选）
        context_fg = "#dcd7ba",
        context_bg = "#1e1e2e",
        separator_fg = "#727169",
      })
    end,
  }
}

-- ============================================================================
-- 插件：barbecue.nvim（状态栏上的面包屑导航）
-- 作用：在窗口顶部显示当前光标所在位置的代码结构路径（如 函数→类→模块），
-- 类似 IDE 的面包屑，点击可跳转。
-- ============================================================================
return {
  "utilyre/barbecue.nvim",
  event = "BufRead",                -- 读入文件时加载
  dependencies = {
    "SmiteshP/nvim-navic",          -- 提供 LSP 符号层级数据
    "nvim-tree/nvim-web-devicons",  -- 图标
  },
  config = function()
    -- 先配置数据源 nvim-navic
    require("nvim-navic").setup({
      lsp = { emmylua_ls = false },  -- 对 lua_ls 禁用（性能考虑）
    })
    -- 再配置面包屑显示
    require("barbecue").setup({
      theme = "auto",                       -- 跟随当前 colorscheme
      symbols = { separator = "" },       -- 层级分隔符图标
      show_modified = true,                 -- 文件被修改时显示标记
    })
  end,
}

-- ============================================================================
-- 插件：nvim-ts-autotag（HTML/XML 自动闭合标签）
-- 作用：输入 <div> 并回车 / 输入 </ 时，自动补全闭合标签，并同步重命名
-- 依赖 Tree-sitter 提供语法分析
-- ============================================================================
return {
  "windwp/nvim-ts-autotag",
  dependencies = "nvim-treesitter/nvim-treesitter", -- 依赖 treesitter
  event = "InsertEnter",                             -- 进入插入模式时加载
  opts = {
    -- 只对这些文件类型启用自动闭合标签
    filetypes = { "html", "xml", "php", "javascript", "typescript", "markdown" },
  },
}

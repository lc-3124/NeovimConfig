-- ============================================================================
-- 插件：render-markdown.nvim（Markdown 渲染）
-- 作用：在编辑 Markdown 时，把表格/代码块/待办/标题等渲染成直观的可视化效果
-- （类似 Typora 的所见即所得），不改变源文件内容。
-- ============================================================================
return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    table = { enabled = true },    -- 渲染表格（对齐、边框线）
    code = { enabled = true },     -- 渲染代码块（背景高亮、语言标签）
    checkbox = { enabled = true }, -- 渲染待办复选框（✓/✗ 图标）
    heading = { enabled = true },  -- 渲染标题（左侧标记、层级颜色）
    bullet = { enabled = true },   -- 渲染列表符号（圆点/图标）
  },
  ft = { "markdown", "Avante" },   -- 只在这些文件类型启用（markdown + AI 对话窗口）
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
}

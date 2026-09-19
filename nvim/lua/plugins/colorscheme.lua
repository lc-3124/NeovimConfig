-- ============================================================================
-- 插件：tokyonight.nvim（主题）
-- 提供 Tokyo Night 配色方案，配合 lua/core/colorscheme.lua 使用
-- ============================================================================
return {
  "folke/tokyonight.nvim",
  lazy = false,            -- 启动时立即加载（主题需要尽早生效）
  priority = 1000,         -- 高优先级，确保在其它插件之前加载主题色
  opts = {
    style = "storm",       -- 主题风格：storm（蓝调），可选 night/day/moon
    terminal_colors = true, -- 终端配色也套用主题
    styles = {
      comments = { italic = true },   -- 注释斜体
      keywords = { italic = true },   -- 关键字斜体
      sidebars = "dark",              -- 侧边栏（如文件树）用深色背景
      floats = "dark",                -- 浮窗（补全/文档）深色背景
    },
    cache = true,          -- 缓存高亮组，加快启动
  },
}

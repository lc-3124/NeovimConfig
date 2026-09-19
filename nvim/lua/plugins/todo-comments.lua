-- ============================================================================
-- 插件：todo-comments.nvim（TODO 注释高亮）
-- 作用：把代码注释里的 TODO/FIX/HACK 等关键字高亮出来，并支持按关键字搜索。
-- 可自定义关键字的图标与颜色分类。
-- ============================================================================
return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",  -- 启动后期加载
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    signs = true,      -- 在符号列显示关键字图标
    -- 自定义关键字表：图标 + 颜色等级 + 同义词
    keywords = {
      FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
    merge_keywords = true,  -- 把 alt 同义词合并进主关键字的高亮
    highlight = {
      multiline = true,          -- 高亮跨行
      multiline_indent = 2,      -- 跨行缩进深度
      before = "",               -- 关键字前的额外文本
      keyword = "wide",          -- 关键字高亮范围
      after = "",                -- 关键字后的额外文本
      -- 匹配模式：如 "TODO:" 冒号形式也识别
      pattern = [[.*<(KEYWORDS)\s*(:)]],
    },
    search = {
      pattern = [[\b(KEYWORDS)\b]],  -- 搜索时的匹配模式
    },
  },
}

-- ============================================================================
-- 插件：snacks.nvim（全能工具集）
-- 作用：folke 出品的一系列增强模块合集，这里启用了：
--   * bigfile / notifier / statuscolumn / words / animate / scroll / input
--   * quickfile / indent / scope / dim
-- 同时把 Dashboard（启动页）、缓冲区删除、通知等绑上快捷键。
-- ============================================================================
return {
  "folke/snacks.nvim",
  priority = 1000,   -- 高优先级提前加载
  lazy = false,      -- 启动即加载（许多模块需要在启动早期就绪）
  opts = {
    bigfile = { enabled = true },      -- 大文件自动禁用部分增强，避免卡顿
    notifier = { enabled = false },     -- 增强型通知（右上角弹出）
    statuscolumn = { enabled = true }, -- 增强行号/符号列（折叠与诊断整合）
    words = { enabled = true },        -- 高亮当前光标下的词的所有出现
    animate = { enabled = false },      -- 动画过渡（滚动/窗口等）
    scroll = { enabled = false },       -- 平滑滚动
    input = { enabled = false },       -- 增强输入框
    quickfile = { enabled = true },    -- 记录最近打开文件
    indent = { enabled = true },       -- 缩进引导线
    scope = { enabled = true },        -- 高亮当前代码块范围
    dashboard = { enabled = false },   -- 关闭启动页：保留 nvim 原生初始画面（需要时 <leader>dd 手动打开）
    dim = { enabled = true },          -- 失焦窗口变暗（split 时）
  },
  keys = {
    { "<leader>dd", function() Snacks.dashboard() end, desc = "打开启动页" },        -- 启动页
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "删除缓冲区" },       -- 删 buffer 保留窗口
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "关闭通知" },     -- 隐藏通知
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "通知历史" }, -- 通知历史
  },
}

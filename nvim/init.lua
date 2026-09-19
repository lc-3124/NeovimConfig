-- ============================================================================
-- Neovim 配置入口（init.lua）
-- 本文件是整个 nvim 配置的起点，负责：
--   1. 设置 leader 键
--   2. 引导并安装 lazy.nvim 插件管理器
--   3. 加载所有插件配置（lua/plugins/ 目录下自动导入）
--   4. 加载核心配置模块（lua/core/ 目录）
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Leader 键设置
-- leader（前缀键）：配合 <leader>xxx 的快捷键使用，这里设为反斜杠 "\"
--   * 全局 leader 用于绝大多数自定义快捷键，如 <leader>w 保存、<leader>q 关闭
--   * 局部 leader 一般用于 buffer 级映射
-- ----------------------------------------------------------------------------
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","

-- ----------------------------------------------------------------------------
-- lazy.nvim 引导（bootstrap）
-- lazy.nvim 是当前使用的插件管理器。若其尚未安装（首次启动），
-- 这里会用 git 把它克隆到 Neovim 的 data 目录下，实现"开箱即用"。
-- ----------------------------------------------------------------------------
-- stdpath("data") = ~/.local/share/nvim，lazy 安装位置
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  -- 浅克隆（--filter=blob:none 只拉取需要的文件，加速下载），使用 stable 稳定分支
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
-- 把 lazy.nvim 加入 runtimepath，使 require("lazy") 可用
vim.opt.rtp:prepend(lazypath)

-- ----------------------------------------------------------------------------
-- lazy.nvim 初始化
-- 第一项 { import = "plugins" }：自动加载 lua/plugins/ 下所有插件配置
--   每个插件配置是一个 return {...} 的 Lua 文件，lazy 会按 spec 语法解析
-- ----------------------------------------------------------------------------
require("lazy").setup({
  { import = "plugins" },
}, {
  -- 全局 UI 配置：
  ui            = { notify = false },          -- 用 snacks 通知替代 lazy 自带的
  change_detection = { notify = false },       -- 插件 spec 变更时不弹通知打扰
  checker       = { enabled = false },         -- 关闭插件更新检查（手动更新）
})

-- ----------------------------------------------------------------------------
-- 加载核心配置模块（lua/core/ 目录）
-- 顺序即加载顺序，每个模块负责一类基础配置：
--   options      → 编辑器基础选项（行号、缩进、搜索等）
--   keymaps      → 全局快捷键
--   autocmds     → 自动命令（恢复光标位置等）
--   colorscheme  → 主题
--   treesitter   → Tree-sitter 语法解析器管理
-- ----------------------------------------------------------------------------
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.colorscheme")
require("core.treesitter")

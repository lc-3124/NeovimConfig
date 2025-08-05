-- init.lua
-- By `lc3124`                        

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#202E36", force = true })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#FF00F0", bg = "#202E36", force = true })
  end
})

-- LAZY `NVIM`
-- 指定插件位置，不存在则clone到本地
local lazypath = vim.fn.stdpath("data") .. "~/.config/nvim/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", 
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" }
}, {
  ui = { notify = false },
  change_detection = { notify = false },
  checker = { enabled = false },
})

vim.cmd[[colorscheme neodark]]

-- 基础配置
-- 基础编辑器设置
vim.opt.guifont = "Hack:h12"               -- 字体设置
vim.opt.number = true                       -- 显示行号
vim.opt.cursorline = true                   -- 高亮当前行
vim.opt.showmatch = true                    -- 高亮匹配括号 [1,4](@ref)
vim.opt.matchtime = 1                       -- 括号匹配高亮时间(0.1秒)
vim.opt.ignorecase = true                    -- 搜索忽略大小写
vim.opt.smartcase = true                     -- 智能大小写检测
vim.opt.expandtab = true                     -- Tab转空格
vim.opt.tabstop = 2                          -- Tab显示宽度
vim.opt.shiftwidth = 2                       -- 自动缩进宽度
vim.opt.softtabstop = -1                     -- 使用 shiftwidth 值 [1](@ref)
vim.opt.autoindent = true                    -- 自动缩进 [4](@ref)
vim.opt.backup = false                       -- 禁用备份文件
vim.opt.writebackup = false                  -- 禁用写入备份
vim.opt.history = 1000                       -- 命令历史记录
vim.opt.scrolloff = 5                        -- 上下滚动保留行数
vim.opt.signcolumn = "yes"                   -- 始终显示标记列
vim.opt.cmdheight = 1                        -- 命令栏高度
vim.opt.wrap = false                         -- 禁用自动换行


-- 语法与文件类型
vim.cmd("syntax enable")                    -- 启用语法高亮 [1](@ref)
vim.cmd("filetype plugin indent on")        -- 启用文件类型检测

-- 快捷键映射
-- 基础操作
-- vim.keymap.set("n", "<Space>", ":w<CR>")    -- 空格保存文件
--vim.keymap.set("i", "jj", "<Esc>")           -- `jj` 退出插入模式 [1](@ref)
vim.keymap.set("n", "<S-j>", "<C-d>")       -- Shift+j 向下翻页
vim.keymap.set("n", "<S-k>", "<C-u>")       -- Shift+k 向上翻页

-- 自动命令
-- 退出插入模式时禁用 fcitx 输入法
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "silent !fcitx5-remote -c"
})

-- 进入插入模式时恢复输入法
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    if vim.v.fcitx5state == "2" then  -- 检查输入法状态
      vim.cmd("silent !fcitx5-remote -o")
    end
  end
})

-- 恢复上次编辑位置 [1](@ref)
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end
})

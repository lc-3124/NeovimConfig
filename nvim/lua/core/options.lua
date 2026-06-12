vim.opt.guifont = "Hack:h12"
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.showmatch = true
vim.opt.matchtime = 1
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.history = 1000
vim.opt.scrolloff = 5
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.wrap = false
vim.opt.updatetime = 300
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.laststatus = 3
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.pumheight = 10
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 2

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

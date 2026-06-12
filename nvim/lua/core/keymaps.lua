local map = vim.keymap.set

map("n", "<S-j>", "<C-d>", { desc = "向下翻半页" })
map("n", "<S-k>", "<C-u>", { desc = "向上翻半页" })
map("n", "<leader>w", ":w<CR>", { desc = "保存文件" })
map("n", "<leader>q", ":q<CR>", { desc = "关闭窗口" })

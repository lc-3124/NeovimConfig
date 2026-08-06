local map = vim.keymap.set

map("n", "<S-j>", "<C-d>", { desc = "向下翻半页" })
map("n", "<S-k>", "<C-u>", { desc = "向上翻半页" })
map("n", "<leader>w", ":w<CR>", { desc = "保存文件" })
map("n", "<leader>q", ":q<CR>", { desc = "关闭窗口" })
map("n", "<leader>ya", ":%y+<CR>", { desc = "复制整个文件" })
map("v", "<leader>y", '"+y', { desc = "复制到系统剪贴板" })

for i = 1, 9 do
  map("n", ("<leader>b%d"):format(i), (":buffer %d<CR>"):format(i), { desc = ("跳转到缓冲区 %d"):format(i) })
end
map("n", "<leader>b0", ":buffer 10<CR>", { desc = "跳转到缓冲区 10" })

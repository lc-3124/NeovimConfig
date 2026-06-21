local autocmd = vim.api.nvim_create_autocmd

autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("CursorRestore", {}),
  pattern = "*",
  callback = function()
    local ok, mark = pcall(vim.fn.line, [=[['"]]=])
    if ok and mark > 1 and mark <= vim.fn.line("$") then
      pcall(vim.cmd, [[normal! g'"]])
    end
  end,
})

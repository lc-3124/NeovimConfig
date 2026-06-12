local autocmd = vim.api.nvim_create_autocmd

local function fcitx_available()
  return vim.fn.executable("fcitx5-remote") == 1
end

autocmd("InsertLeave", {
  group = vim.api.nvim_create_augroup("FcitxConfig", {}),
  pattern = "*",
  callback = function()
    if fcitx_available() then
      vim.fn.system("fcitx5-remote -c")
    end
  end,
})

autocmd("InsertEnter", {
  group = vim.api.nvim_create_augroup("FcitxConfig", {}),
  pattern = "*",
  callback = function()
    if fcitx_available() and vim.v.fcitx5state == "2" then
      vim.fn.system("fcitx5-remote -o")
    end
  end,
})

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

local parser_dir = vim.fn.stdpath("data") .. "/site/parser/"
vim.fn.mkdir(parser_dir, "p")

local grammars = {
  make            = { repo = "tree-sitter-grammars/tree-sitter-make" },
  markdown        = { repo = "tree-sitter-grammars/tree-sitter-markdown", src = "tree-sitter-markdown/src" },
  markdown_inline = { repo = "tree-sitter-grammars/tree-sitter-markdown", src = "tree-sitter-markdown-inline/src" },
  lua             = { repo = "tree-sitter-grammars/tree-sitter-lua" },
  vim             = { repo = "neovim/tree-sitter-vim" },
  vimdoc          = { repo = "neovim/tree-sitter-vimdoc" },
  c               = { repo = "tree-sitter/tree-sitter-c" },
  python          = { repo = "tree-sitter/tree-sitter-python" },
  json            = { repo = "tree-sitter/tree-sitter-json" },
  yaml            = { repo = "tree-sitter-grammars/tree-sitter-yaml" },
  toml            = { repo = "tree-sitter-grammars/tree-sitter-toml" },
  html            = { repo = "tree-sitter/tree-sitter-html" },
  css             = { repo = "tree-sitter/tree-sitter-css" },
  javascript      = { repo = "tree-sitter/tree-sitter-javascript" },
  typescript      = { repo = "tree-sitter/tree-sitter-typescript", src = "typescript/src" },
  rust            = { repo = "tree-sitter/tree-sitter-rust" },
}

vim.treesitter.language.register("markdown", { "markdown", "mdx" })
vim.treesitter.language.register("markdown_inline", "markdown_inline")
vim.treesitter.language.register("make", "make")

local ts_filetypes = {
  "make", "markdown", "lua", "vim", "vimdoc",
  "c", "python", "json", "yaml", "toml", "html", "css",
  "typescript", "javascript", "rust",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  callback = function()
    if not pcall(vim.treesitter.start) then vim.cmd("syntax enable") end
  end,
})

local function install_parser(lang)
  if not grammars[lang] then
    vim.notify("Unknown parser: " .. lang, vim.log.levels.ERROR)
    return
  end

  local g = grammars[lang]
  local work = "/tmp/ts-install-" .. lang .. "/"
  vim.fn.system({ "rm", "-rf", work })
  local src_dir = work .. (g.src or "src")

  vim.fn.system({ "git", "clone", "--depth", "1",
    "https://github.com/" .. g.repo .. ".git", work })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to clone " .. g.repo, vim.log.levels.ERROR)
    return
  end

  local scanner = vim.fn.filereadable(src_dir .. "/scanner.c") == 1
    and (" " .. src_dir .. "/scanner.c") or ""

  local cmd = string.format("cc -shared -fPIC -O2 -o %s/%s.so %s/parser.c%s -I%s",
    parser_dir, lang, src_dir, scanner, src_dir)
  vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to compile parser: " .. lang, vim.log.levels.ERROR)
    return
  end

  vim.fn.system({ "rm", "-rf", work })

  local query_dir = vim.fn.stdpath("data") .. "/site/queries/" .. lang .. "/"
  vim.fn.mkdir(query_dir, "p")
  for _, q in ipairs({ "highlights", "folds", "injections", "indents" }) do
    local url = string.format("https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/main/runtime/queries/%s/%s.scm", lang, q)
    vim.fn.system({ "curl", "-sfL", url, "-o", query_dir .. q .. ".scm" })
  end

  vim.notify("Installed tree-sitter parser: " .. lang)
end

vim.api.nvim_create_user_command("TSInstall", function(args)
  install_parser(args.args)
end, {
  nargs = 1,
  complete = function()
    local installed = {}
    local dir = vim.fn.stdpath("data") .. "/site/parser"
    if vim.fn.isdirectory(dir) == 1 then
      for _, f in ipairs(vim.fn.readdir(dir)) do
        installed[f:match("(.+)%.so$")] = true
      end
    end
    local available = {}
    for name in pairs(grammars) do
      if not installed[name] then table.insert(available, name) end
    end
    return available
  end,
})

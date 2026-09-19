-- ============================================================================
-- Tree-sitter 模块
-- Tree-sitter 是一个增量语法解析器，为代码提供精确的高亮/折叠/缩进/跳转。
-- 本模块实现了一个"手动编译 parser"的方案：
--   从 GitHub 克隆各语言的 parser 源码 → 用 cc 编译成 .so → 放入 Neovim 目录
-- 这样做的好处是不依赖 nvim-treesitter 插件，配置更轻。
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. 准备 parser 存放目录
-- parser 编译产物（.so）会放到 ~/.local/share/nvim/site/parser/ 下
-- ----------------------------------------------------------------------------
local parser_dir = vim.fn.stdpath("data") .. "/site/parser/"
vim.fn.mkdir(parser_dir, "p")   -- 不存在则递归创建

-- ----------------------------------------------------------------------------
-- 1. 支持的语言清单：语言名 → { GitHub 仓库, 可选源码子目录 src }
--    repo 是 GitHub 上的仓库路径；部分语言需要指定 src 子目录
--    这里的 src 字段对应仓库内的 parser.c 所在目录
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2. 语言别名注册
-- 某些文件类型（filetype）要映射到 parser 语言名。
-- 例如 markdown 文件同时用 markdown 和 markdown_inline 两种 parser。
-- ----------------------------------------------------------------------------
vim.treesitter.language.register("markdown", { "markdown", "mdx" })
vim.treesitter.language.register("markdown_inline", "markdown_inline")
vim.treesitter.language.register("make", "make")

-- ----------------------------------------------------------------------------
-- 3. 对支持的文件类型自动启用 Tree-sitter
-- FileType 事件触发时，尝试 vim.treesitter.start 启用解析器；
-- 若解析器尚未安装（pcall 失败），回退到传统语法高亮（syntax enable）
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 4. 手动编译并安装某个语言的 parser
-- 流程：克隆源码 → 用 cc 编译 parser.c → 产物 .so 放 parser_dir
--        → 下载高亮/折叠等查询文件到 queries 目录
-- 供命令 :TSInstall <语言> 调用（见下方用户命令定义）
-- ----------------------------------------------------------------------------
local function install_parser(lang)
  -- 语言不在清单里则报错
  if not grammars[lang] then
    vim.notify("Unknown parser: " .. lang, vim.log.levels.ERROR)
    return
  end

  local g = grammars[lang]
  local work = "/tmp/ts-install-" .. lang .. "/"   -- 临时工作目录
  vim.fn.system({ "rm", "-rf", work })             -- 清理旧临时目录

  -- parser.c 所在目录：默认 src/，特殊语言用 grammars 里指定的 src
  local src_dir = work .. (g.src or "src")

  -- 浅克隆仓库（--depth 1 只拉最新一版）
  vim.fn.system({ "git", "clone", "--depth", "1",
    "https://github.com/" .. g.repo .. ".git", work })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to clone " .. g.repo, vim.log.levels.ERROR)
    return
  end

  -- 若源码目录存在 scanner.c，编译时需要一起包含（词法器实现）
  local scanner = vim.fn.filereadable(src_dir .. "/scanner.c") == 1
    and (" " .. src_dir .. "/scanner.c") or ""

  -- 编译：cc 生成共享库 <lang>.so
  --   -shared 输出动态库；-fPIC 位置无关代码；-O2 优化
  local cmd = string.format("cc -shared -fPIC -O2 -o %s/%s.so %s/parser.c%s -I%s",
    parser_dir, lang, src_dir, scanner, src_dir)
  vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to compile parser: " .. lang, vim.log.levels.ERROR)
    return
  end

  -- 清理临时目录
  vim.fn.system({ "rm", "-rf", work })

  -- 下载查询文件（.scm）：高亮、折叠、注入、缩进
  -- 来源是 nvim-treesitter 官方仓库的 runtime/queries/<lang>/ 目录
  local query_dir = vim.fn.stdpath("data") .. "/site/queries/" .. lang .. "/"
  vim.fn.mkdir(query_dir, "p")
  for _, q in ipairs({ "highlights", "folds", "injections", "indents" }) do
    local url = string.format("https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/main/runtime/queries/%s/%s.scm", lang, q)
    vim.fn.system({ "curl", "-sfL", url, "-o", query_dir .. q .. ".scm" })
  end

  vim.notify("Installed tree-sitter parser: " .. lang)
end

-- ----------------------------------------------------------------------------
-- 5. 用户命令 :TSInstall <语言>
-- 提供补全：只列出"已定义但尚未安装"的语言
-- ----------------------------------------------------------------------------
vim.api.nvim_create_user_command("TSInstall", function(args)
  install_parser(args.args)
end, {
  nargs = 1,   -- 需要一个参数（语言名）
  complete = function()
    -- 已安装的（parser 目录下存在 <name>.so）
    local installed = {}
    local dir = vim.fn.stdpath("data") .. "/site/parser"
    if vim.fn.isdirectory(dir) == 1 then
      for _, f in ipairs(vim.fn.readdir(dir)) do
        installed[f:match("(.+)%.so$")] = true
      end
    end
    -- 可安装的 = 清单里去掉已安装的
    local available = {}
    for name in pairs(grammars) do
      if not installed[name] then table.insert(available, name) end
    end
    return available
  end,
})

-- ============================================================================
-- 插件：nvim-lspconfig + mason（LSP 语言服务器）
-- 作用：
--   * mason.nvim：管理语言服务器的安装/更新（类似包管理器）
--   * nvim-lspconfig：为各语言服务器提供 Neovim 集成与快捷键
--   * 这里统一配置了诊断显示、LSP 快捷键、以及要安装的服务器清单
-- ============================================================================
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },  -- 打开文件时加载
    dependencies = {
      "williamboman/mason.nvim",             -- 服务器安装器
      "williamboman/mason-lspconfig.nvim",   -- 连接 mason 与 lspconfig
      "hrsh7th/cmp-nvim-lsp",                -- 让补全获得 LSP 能力
    },
    config = function()
      -- 从 cmp-nvim-lsp 获取标准 LSP capabilities（补全/悬浮等能力声明）
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- ----------------------------------------------------------------------
      -- 诊断符号（sign column 里显示的图标）
      -- ----------------------------------------------------------------------
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋼 " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- ----------------------------------------------------------------------
      -- 悬浮文档（hover）用圆角边框
      -- ----------------------------------------------------------------------
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = "rounded" })
        vim.lsp.handlers.hover(err, result, ctx, config)
      end

      -- ----------------------------------------------------------------------
      -- 全局诊断显示配置
      -- ----------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },  -- 行内诊断前缀符号
        signs = true,                     -- 显示符号列诊断
        update_in_insert = true,          -- 插入模式下也实时更新诊断
        severity_sort = true,             -- 按严重级别排序
        float = { border = "rounded" },   -- 诊断浮窗圆角
      })

      -- ----------------------------------------------------------------------
      -- LSP 快捷键（LspAttach：每个 buffer 连上 LSP 时注册）
      -- ----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = ev.buf, desc = "语法帮助" }) -- 悬浮文档
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "跳转定义" }) -- 跳转定义（Gramma Definition）
          vim.keymap.set("n", "gf", "<C-o>", { buffer = ev.buf, desc = "返回上一个位置" }) -- 返回上一个跳转位置（Gramma Fallback）
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "跳转实现" }) -- 跳转实现
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "查找引用" }) -- 查找引用
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "重命名符号" }) -- 重命名
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "代码操作" }) -- 代码操作
          vim.keymap.set("n", "<leader>f", function()                      -- 格式化
            vim.lsp.buf.format({ async = true })
          end, { buffer = ev.buf, desc = "格式化代码" })
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, { buffer = ev.buf, desc = "悬浮诊断" }) -- 悬浮诊断
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = ev.buf, desc = "上一个诊断" }) -- 上一个诊断
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = ev.buf, desc = "下一个诊断" }) -- 下一个诊断
          vim.keymap.set("n", "<leader>lh", function()                     -- 切换 inlay hint（内联类型提示）
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, { buffer = ev.buf, desc = "切换内联类型提示" })
        end,
      })

      -- ----------------------------------------------------------------------
      -- mason-lspconfig：声明要自动安装的语言服务器
      -- ----------------------------------------------------------------------
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",        -- Lua
          "clangd",        -- C/C++
          "pyright",       -- Python
          "rust_analyzer", -- Rust
          "ts_ls",         -- TypeScript/JavaScript
          "marksman",      -- Markdown
        },
        -- 统一的启动处理器：给每个服务器注入 capabilities
        handlers = {
          function(server_name)
            local server_opts = { capabilities = capabilities }
            -- Lua 服务器特殊配置：让 lua_ls 认识 vim 全局，并加载 Neovim 运行时库
            if server_name == "lua_ls" then
              server_opts.settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },   -- 避免 vim 未定义告警
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true), -- 加载 nvim runtime 的类型
                    checkThirdParty = false,               -- 不检查第三方库
                  },
                  telemetry = { enable = false },          -- 关闭遥测
                },
              }
            end
            require("lspconfig")[server_name].setup(server_opts)
          end,
        },
      })
    end,
  },
  -- --------------------------------------------------------------------------
  -- mason.nvim 主插件：用 :Mason 命令打开安装界面
  -- --------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = "Mason",           -- 按需加载（执行 :Mason 时才加载）
    build = ":MasonUpdate",  -- 更新注册表
    opts = {},
  },
  -- --------------------------------------------------------------------------
  -- mason-lspconfig 本体（连接上面两者）
  -- --------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },
}

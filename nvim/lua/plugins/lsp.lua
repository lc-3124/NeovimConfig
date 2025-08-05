-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()

      -- 先设置主题相关的高亮组
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#7e9cd8", bg = "#1e1e2e" })  -- 悬浮窗口边框
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e" })                 -- 悬浮窗口背景
      vim.api.nvim_set_hl(0, "LspFloatWinNormal", { bg = "#1e1e2e" })           -- LSP 浮动窗口
      vim.api.nvim_set_hl(0, "DiagnosticFloating", { bg = "#1e1e2e" })          -- 诊断窗口背景

      -- 诊断信息颜色（适配 `NeoDark`）
      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#e46876" })  -- 错误
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#d7a65a" })   -- 警告
      vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#7e9cd8" })   -- 信息
      vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#6a9589" })   -- 提示

      -- 面包屑导航颜色
      vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#363646" })  -- 代码引用
      vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#363646" })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#363646" })

      -- 设置 LSP 相关快捷键
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- 启用面包屑导航
          vim.opt_local.winbar = "%=%m %f"

          -- 快捷键绑定
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '<leader>ggD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>ggi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>g<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
      -- 自动显示诊断信息（悬停时）
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
          silent = true,
          -- 添加这些样式配置
          style = "minimal",
          focusable = false,
          max_width = 80,
          max_height = 30,
        }
      )

      -- 显示诊断信息（浮动窗口）
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",  -- 改为圆点图标
          spacing = 4,
          severity = {
            min = vim.diagnostic.severity.HINT,
          },
        },
        float = {
          border = "rounded",
          source = "always",
          header = "",
          header = "",
          -- 关键设置：强制使用自定义背景色
          focusable = false,
          close_events = { "CursorMoved", "CursorMovedI" },
          -- 直接指定窗口样式
          winhighlight = "NormalFloat:DiagnosticFloating,BorderFloat:DiagnosticFloatingBorder",
          prefix = function(diagnostic)
            local icons = {
              Error = " ",
              Warn = " ",
              Info = " ",
              Hint = " ",
            }
            return icons[diagnostic.severity]
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      vim.o.updatetime = 500  -- 单位是毫秒
      -- 设置悬停自动触发诊断
      vim.api.nvim_create_autocmd("CursorHold", {
        pattern = "*",
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
            border = "rounded",
            source = "always",
          })
        end,
      })
      -- 添加诊断符号
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- 语言服务器配置
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- 通用服务器配置
      local servers = {
        'clangd',       -- C/C++
        'pyright',      -- Python
        'lua_ls',       -- Lua
        'jsonls',       -- JSON
        'marksman',     -- Markdown
      }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = capabilities,
        }
      end

      -- Lua 特殊配置
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }
      require("lspconfig").clangd.setup({
        root_dir = function()
          return vim.fn.getcwd()  -- 返回 nvim 启动时的目录
        end,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

    end
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
    cmd = "Mason",
    build = ":MasonUpdate",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    config = true,
  }
}

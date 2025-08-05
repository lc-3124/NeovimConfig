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
          vim.keymap.set('n', '<leade>ggi', vim.lsp.buf.implementation, opts)
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
          border = "rounded",  -- 边框样式
          silent = true,       -- 不显示多余提示
        }
      )

      -- 自动显示诊断信息（浮动窗口）
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = true,  -- 行内虚拟文本
          signs = true,          -- 显示左侧标记
          underline = true,      -- 显示错误下划线
          update_in_insert = false,
          -- 忽略参数错误
          float = {             -- 悬停时显示浮动窗口
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",   -- 显示诊断来源
            header = "",
            prefix = "",
          },
        }
      )
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
          return vim.fn.getcwd()  -- 返回 `nvim` 启动时的目录
        end,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--query-driver=/usr/bin/g++,/usr/bin/clang++",  -- 指定有效编译器
          "--offset-encoding=utf-16",  -- 防止跳转位置错乱
        },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
        }
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

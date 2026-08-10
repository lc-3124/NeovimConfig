-- ============================================================================
-- 插件：nvim-cmp（补全引擎）+ 相关依赖
-- 作用：统一所有来源（LSP、代码片段、buffer 内容、文件路径）的补全，
-- 是 Neovim 补全的核心。
-- ============================================================================
return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",   -- 进入插入模式才加载
    dependencies = {
      "hrsh7th/cmp-buffer",          -- 补全来源：当前 buffer 内容
      "hrsh7th/cmp-path",            -- 补全来源：文件路径
      "hrsh7th/cmp-nvim-lsp",        -- 补全来源：LSP 语义
      "saadparwaiz1/cmp_luasnip",    -- 补全来源：代码片段
      "L3MON4D3/LuaSnip",            -- 代码片段引擎
      "rafamadriz/friendly-snippets",-- 常用代码片段集
      "ray-x/lsp_signature.nvim",    -- 函数签名提示（输入参数时显示）
      "windwp/nvim-autopairs",       -- 与自动成对补全联动
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- 延迟加载 VS Code 风格的代码片段（friendly-snippets）
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- 代码片段展开：交给 LuaSnip 处理
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        -- 补全弹窗的按键映射
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),      -- Ctrl+B 向上翻文档
          ["<C-f>"] = cmp.mapping.scroll_docs(4),       -- Ctrl+F 向下翻文档
          ["<C-Space>"] = cmp.mapping.complete(),       -- Ctrl+Space 手动触发补全
          ["<C-e>"] = cmp.mapping.abort(),              -- Ctrl+E 取消补全
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认选中项
          -- Tab：有补全→选下一个；否则可跳 snippet 的下一个占位符
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Shift+Tab：选上一个 / 回退到 snippet 上一个占位符
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- 补全来源优先级：LSP > 片段 > buffer > 路径
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- 函数签名提示配置：调用函数时底部/光标处显示参数说明
      require("lsp_signature").setup({
        bind = true,                     -- 自动绑定
        hint_enable = true,              -- 启用提示
        handler_opts = { border = "rounded" }, -- 圆角边框
        zindex = 50,                     -- 层叠顺序
        fix_pos = true,                  -- 固定提示位置避免跳动
        toggle_key = "<C-s>",            -- Ctrl+S 切换显示
      })

      -- 联动 autopairs：补全选中括号类内容后，自动补出配对符号
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}

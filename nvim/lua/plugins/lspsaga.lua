-- ============================================================================
-- 插件：lspsaga.nvim（这里只用它的 outline 符号大纲）
-- 作用：右侧符号大纲，名字右侧以「非强调」样式显示 LSP detail（签名/参数）。
-- 额外定制：
--   * enum 完全不展开：过滤掉 Enum(10) 的 EnumMember(22) 子节点，enum 变成叶子
--   * 一键全部折叠：zM 或 C（命令 :LspsagaCollapseAll）
-- 键位：\cs 或 F9 开关；栏内 o=展开或跳转，e/Enter/双击=跳转，zM/C=全部折叠，q/Esc=关闭。
-- ============================================================================
return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- 关闭其它模块，避免与 lsp.lua / barbecue / 现有诊断键位打架
    lightbulb = { enable = false },
    symbol_in_winbar = { enable = false },
    diagnostic = { show_code_action = false },
    -- 只保留：符号大纲
    outline = {
      win_position = "right",  -- 右侧
      win_width = 30,
      auto_preview = false,    -- 关闭悬浮预览（不显示源码预览）
      detail = true,           -- 名字右侧显示 detail（非强调）
      auto_close = true,       -- 只剩大纲窗口时自动关闭
      close_after_jump = false,
      layout = "normal",       -- 侧栏（非浮动）
      max_height = 0.5,
      left_width = 0.3,
      keys = {
        toggle_or_jump = "o",  -- 有子节点则展开/折叠，否则跳转
        jump = { "e", "<CR>", "<2-LeftMouse>" },  -- e / Enter / 双击 跳转源码
        quit = { "q", "<Esc>" },
      },
    },
  },
  config = function(_, opts)
    require("lspsaga").setup(opts)
    vim.api.nvim_set_hl(0, "SagaDetail", { link = "Comment" })  -- detail 用注释色（非强调）

    -- enum 完全不展开：去掉 Enum(10) 节点的 EnumMember(22) 子节点，使其成为叶子
    local ENUM = 10
    local function strip_enum_members(list)
      if type(list) ~= "table" then return end
      for _, n in ipairs(list) do
        if type(n) == "table" then
          if n.kind == ENUM then
            n.children = nil
          elseif n.children then
            strip_enum_members(n.children)
          end
        end
      end
    end
    for _, modname in ipairs({ "lspsaga.symbol", "lspsaga.symbol.head" }) do
      local ok, mod = pcall(require, modname)
      if ok and type(mod) == "table" and mod.get_buf_symbols then
        local orig = mod.get_buf_symbols
        mod.get_buf_symbols = function(self, buf)
          local res = orig(self, buf)
          if res and res.symbols then strip_enum_members(res.symbols) end
          return res
        end
      end
    end

    local function get_outline()
      local ok, ot = pcall(require, "lspsaga.symbol.outline")
      if ok and ot and ot.winid and vim.api.nvim_win_is_valid(ot.winid) and ot.list then
        return ot
      end
      return nil
    end

    -- 折叠所有"已展开且有子节点"的节点；kinds 为 nil 表示所有 kind，否则只折叠指定 kind 集合
    local function collapse(kinds)
      local ot = get_outline()
      if not ot then return false end
      local lines = {}
      local node = ot.list
      while node do
        local v = node.value
        if v and v.expand and v.virtid and (not kinds or (v.kind and kinds[v.kind])) then
          lines[#lines + 1] = v.winline
        end
        node = node.next
      end
      table.sort(lines, function(a, b) return a > b end)  -- 自下而上，避免行号错位

      if #lines > 0 then
        -- toggle_or_jump 依赖"当前窗口是大纲"，先聚焦再操作
        local prev = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(ot.winid)
        for _, ln in ipairs(lines) do
          if vim.api.nvim_win_is_valid(ot.winid) then
            vim.api.nvim_win_set_cursor(ot.winid, { ln, 0 })
            ot:toggle_or_jump()
          end
        end
        if prev ~= ot.winid and vim.api.nvim_win_is_valid(prev) then
          vim.api.nvim_set_current_win(prev)
        end
      end
      return true
    end

    local function collapse_all()
      if not collapse(nil) then
        vim.notify("[lspsaga] 大纲未打开", vim.log.levels.INFO)
      end
    end

    vim.api.nvim_create_user_command("LspsagaCollapseAll", collapse_all, { desc = "符号大纲：全部折叠" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "sagaoutline",
      callback = function(args)
        vim.keymap.set("n", "zM", collapse_all, { buffer = args.buf, desc = "全部折叠" })
        vim.keymap.set("n", "C",  collapse_all, { buffer = args.buf, desc = "全部折叠" })
      end,
    })
  end,
  keys = {
    { "<leader>cs", "<cmd>Lspsaga outline<cr>", desc = "符号大纲（Saga）" },
    { "<F9>",       "<cmd>Lspsaga outline<cr>", desc = "符号大纲（Saga）" },
  },
}

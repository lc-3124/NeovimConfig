-- ============================================================================
-- 插件：gitsigns.nvim（Git 改动标记）
-- 作用：在符号列/行内显示 Git 的增删改标记，并提供暂存/对比等操作快捷键。
-- ============================================================================
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },  -- 打开文件时加载
  opts = {
    -- 符号列中显示的标记字符
    signs = {
      add = { text = "│" },        -- 新增行
      change = { text = "│" },     -- 修改行
      delete = { text = "_" },     -- 删除行
      topdelete = { text = "‾" },  -- 顶部删除
      changedelete = { text = "~" }, -- 修改且删除
      untracked = { text = "┆" },  -- 未跟踪
    },
    update_debounce = 200,          -- 更新标记的防抖时间（毫秒）
    current_line_blame = false,     -- 默认关闭行内 blame（用快捷键手动开）
    preview_config = { border = "rounded" }, -- 预览窗口圆角边框
    on_attach = function(bufnr)
      -- 在 attach 时注册本 buffer 的快捷键
      local gs = package.loaded.gitsigns
      local map = function(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end
      -- 在 diff 模式下保留原生 ]c/[c 行为，否则跳到下一/上一处改动
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "下一处改动" })
      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "上一处改动" })

      -- \gs 暂存当前 hunk；可视模式暂存选中范围
      map("n", "<leader>gs", gs.stage_hunk, { desc = "暂存 hunk" })
      map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "暂存选中 hunk" })
      map("n", "<leader>gr", gs.reset_hunk, { desc = "重置 hunk" })          -- 放弃当前改动
      map("n", "<leader>gS", gs.stage_buffer, { desc = "暂存整个文件" })     -- 全部暂存
      map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "撤销暂存" })      -- 取消暂存
      map("n", "<leader>gR", gs.reset_buffer, { desc = "重置文件" })         -- 放弃整个文件
      map("n", "<leader>gp", gs.preview_hunk, { desc = "预览改动" })         -- 浮窗预览
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame 当前行" })
      map("n", "<leader>gB", function() gs.blame() end, { desc = "Buffer Blame" })
      map("n", "<leader>gd", gs.diffthis, { desc = "对比当前文件" })         -- 与 HEAD 对比
      map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "对比上次提交" })
      map("n", "<leader>gt", gs.toggle_signs, { desc = "切换标记显示" })     -- 开关符号列标记
      map("n", "<leader>gT", gs.toggle_current_line_blame, { desc = "切换行内 Blame" })
    end,
  },
}

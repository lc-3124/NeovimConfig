return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    update_debounce = 200,
    current_line_blame = false,
    preview_config = {
      border = "rounded",
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local map = function(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end
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
      map("n", "<leader>gs", gs.stage_hunk, { desc = "暂存 hunk" })
      map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "暂存选中 hunk" })
      map("n", "<leader>gr", gs.reset_hunk, { desc = "重置 hunk" })
      map("n", "<leader>gS", gs.stage_buffer, { desc = "暂存整个文件" })
      map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "撤销暂存" })
      map("n", "<leader>gR", gs.reset_buffer, { desc = "重置文件" })
      map("n", "<leader>gp", gs.preview_hunk, { desc = "预览改动" })
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame 当前行" })
      map("n", "<leader>gB", function() gs.blame() end, { desc = "Buffer Blame" })
      map("n", "<leader>gd", gs.diffthis, { desc = "对比当前文件" })
      map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "对比上次提交" })
      map("n", "<leader>gt", gs.toggle_signs, { desc = "切换标记显示" })
      map("n", "<leader>gT", gs.toggle_current_line_blame, { desc = "切换行内 Blame" })
    end,
  },
}

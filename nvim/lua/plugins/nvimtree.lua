-- ============================================================================
-- 插件：nvim-tree.lua（文件树）
-- 作用：侧边文件浏览器，展示目录结构，支持 Git 状态图标、文件操作等。
-- 默认关闭了内置的 netrw，改用本插件浏览文件。
-- ============================================================================
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- F3 键开关文件树
    { "<F3>", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
  },
  config = function()
    -- 禁用内置文件浏览（netrw），避免与 nvim-tree 冲突
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      sort = { sorter = "case_sensitive" },  -- 按大小写敏感排序
      view = { width = 30, side = "left" },  -- 宽度 30，位于左侧
      renderer = {
        indent_width = 2,      -- 缩进宽度
        group_empty = true,    -- 合并只有一个子目录的空目录
        icons = {
          git_placement = "before",  -- Git 状态图标放在文件名前
          show = { file = true, folder = true, git = true }, -- 显示文件/目录/Git 图标
        },
      },
      filesystem_watchers = { enable = false },  -- 关闭文件系统监听（减少开销）
      git = { enable = true },                   -- 显示 Git 状态
      actions = { open_file = { quit_on_open = false } }, -- 打开文件后不自动关闭树
    })
  end,
}

-- ============================================================================
-- 自动命令模块（autocmds）
-- 定义全局的自动命令，用于在特定事件发生时自动执行动作。
-- ============================================================================

-- 缩写：nvim_create_autocmd → autocmd，方便下面调用
local autocmd = vim.api.nvim_create_autocmd

-- ----------------------------------------------------------------------------
-- 恢复上次编辑位置
-- 事件 BufReadPost：每次读入文件（打开文件）后触发
-- 作用：重新打开一个文件时，自动把光标跳回上次离开时的位置
-- 原理：Vim 会自动记录一个特殊标记 '"（last position），这里读取并跳转
-- ----------------------------------------------------------------------------
autocmd("BufReadPost", {
  -- 建立独立的自动命令组，便于统一管理/清除
  group = vim.api.nvim_create_augroup("CursorRestore", {}),
  pattern = "*",   -- 对所有文件类型生效
  callback = function()
    -- pcall 包裹：防止某些文件类型（如特殊缓冲区）调用出错导致报错
    -- vim.fn.line(['"]) 读取 '" 标记所在的行号
    local ok, mark = pcall(vim.fn.line, [=[['"]]=])
    -- 仅当行号有效：>1（第 1 行无需跳转）且不超过文件总行数
    if ok and mark > 1 and mark <= vim.fn.line("$") then
      -- normal! g'" 跳转到该标记位置（g 用于确定行号的位置）
      pcall(vim.cmd, [[normal! g'"]])
    end
  end,
})

-- ----------------------------------------------------------------------------
-- 启动行为：`nvim <目录>` 时自动打开文件树
-- 事件 VimEnter：nvim 启动完成、进入主窗口时触发
-- 作用：当用 `nvim .`（或任意目录）打开 nvim 时，
-- ----------------------------------------------------------------------------
autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("StartupProjectView", {}),
  callback = function()
    local args = vim.fn.argv()
    -- 仅当第一个参数是存在的目录时触发（排除 nvim 打开单个文件 / 无参数）
    if #args > 0 and vim.fn.isdirectory(args[1]) == 1 then
      -- vim.schedule：把执行延后到启动事件循环结束、所有插件加载完毕
      vim.schedule(function()
        -- NvimTreeOpen 会通过 cmd 懒加载机制触发 nvim-tree 插件加载
        pcall(vim.cmd, "NvimTreeOpen")
      end)
    end
  end,
})

-- ----------------------------------------------------------------------------
-- 行内四分之一跳转（供 keymaps.lua 的 S-H / S-L 使用）
-- 用 _G 全局导出，避免在 keymaps.lua 里定义函数污染纯映射文件；
-- keymaps.lua 的映射回调是懒执行的，按键时才访问本函数（此时已加载）
--   作用：在当前行内向前/向后跳转行宽的四分之一
-- 实现说明：用 strchars（字符数）算行宽，
-- str_utfindex/str_byteindex 在「字符索引 ↔ 字节偏移」间精确换算，
-- 避免中文等宽字符导致的光标定位错乱
-- ----------------------------------------------------------------------------
_G.jump_quarter = function(dir)
  local line = vim.fn.getline(".")                 -- 当前行文本
  local total = vim.fn.strchars(line)              -- 行内总字符数
  if total == 0 then return end                    -- 空行直接返回
  local cur = vim.str_utfindex(line, vim.fn.col(".") - 1) -- 当前光标所在字符索引
  local step = math.max(math.floor(total / 4), 1)  -- 步长 = 行宽四分之一（至少 1）
  -- dir=1 向右跳（索引增大），dir=-1 向左跳（索引减小），并夹在 [0, total] 内
  local target = dir == 1
    and math.min(cur + step, total)
    or math.max(cur - step, 0)
  vim.fn.cursor(".", vim.str_byteindex(line, target) + 1) -- 字符索引转回字节列（1-based）
end

-- ----------------------------------------------------------------------------
-- Tree-sitter 语法树工具（供自定义跳转使用，如 C-j / C-k）
--   设计：
--     _G.ts_root(bufnr)：取指定 buffer 的语法树根节点。
--       带缓存：同一个 buffer 解析一次即可复用；parser 不可用返回 nil。
--     「文件更新时自动更新语法树」：Tree-sitter 的 parse() 本身是增量的，
--       每次调用都基于 buffer 最新内容解析；这里再挂 autocmd，
--       在编辑/写入后清掉缓存，保证下一次 _G.ts_root 一定拿到最新树。
--   用法（在 keymaps.lua 里）：
--       local root = _G.ts_root()
--       然后对 root:iter_children() / node:range() / node:type() 自由遍历
-- ----------------------------------------------------------------------------
local ts_cache = {} -- bufnr -> 语法树根节点

_G.ts_root = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if ts_cache[bufnr] then return ts_cache[bufnr] end -- 命中缓存

  -- 获取该 buffer 的 parser（可能返回 true, nil，需双重判断）
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return nil end
  local tree = parser:parse()[1]
  if not tree then return nil end

  ts_cache[bufnr] = tree:root() -- 缓存根节点
  return ts_cache[bufnr]
end

-- 文件内容变化 / 写入后：清除对应 buffer 的缓存，下次自动重新解析
--   TextChanged / TextChangedI：编辑时（普通模式 / 插入模式）
--   BufWritePost：保存文件后
local ts_group = vim.api.nvim_create_augroup("TsAutoRefresh", { clear = true })
for _, event in ipairs({ "TextChanged", "TextChangedI", "BufWritePost" }) do
  autocmd(event, {
    group = ts_group,
    pattern = "*",
    callback = function()
      ts_cache[vim.api.nvim_get_current_buf()] = nil
    end,
  })
end



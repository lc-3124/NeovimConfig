-- ============================================================================
-- 模块：内置快捷键汉化（keymap-zh）
-- 作用：nvim 自带快捷键 / 部分插件自动注册的快捷键，其 desc（描述）是英文，
--       which-key 弹窗里会原样显示英文。本模块用「英文 desc → 中文」对照表，
--       把当前所有已注册映射的英文 desc 覆盖为中文。
-- 原理：
--   * 按 desc 精确匹配（同一英文描述含义唯一），不会误伤中文自定义映射
--   * 覆盖时保留原映射的 rhs（命令字符串或 Lua 函数）及 expr/noremap/silent 属性
--   * 幂等：翻译过一次的键 desc 变中文，再次执行不会重复处理
-- ============================================================================

-- 中英对照表：keymap 的英文 desc → 中文
local zh = {
  -- 插入/删除空行（[ 与 ] 单键，vim9 新增默认映射）
  ["Add empty line above cursor"] = "在上方插入空行",
  ["Add empty line below cursor"] = "在下方插入空行",

  -- nvim 内置诊断跳转（[d ]d [D ]D）
  ["Jump to the first diagnostic in the current buffer"] = "跳到第一个诊断",
  ["Jump to the previous diagnostic in the current buffer"] = "上一个诊断",
  ["Jump to the last diagnostic in the current buffer"] = "跳到最后一个诊断",
  ["Jump to the next diagnostic in the current buffer"] = "下一个诊断",
  ["Show diagnostics under the cursor"] = "显示光标处诊断",

  -- 系统打开 & 帮助引用类默认行为
  ["Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)"] = "用系统程序打开光标下的文件或链接",
  [":help &-default"] = "重复上一次替换命令",
  [":help Y-default"] = "复制到行尾",
  [":help CTRL-L-default"] = "刷新屏幕并重绘",
  [":help i_CTRL-W-default"] = "删除前一个单词",
  [":help i_CTRL-U-default"] = "删除到行首",
  [":help v_#-default"] = "向前搜索选中的文本",
  [":help v_star-default"] = "向后搜索选中的文本",
  [":help v_@-default"] = "对选中文本执行宏",
  [":help v_Q-default"] = "对选中行执行宏或 Ex 命令",

  -- 缓冲区跳转（[b ]b [B ]B）
  [":brewind"] = "跳到第一个缓冲区",
  [":bprevious"] = "上一个缓冲区",
  [":blast"] = "跳到最后一个缓冲区",
  [":bnext"] = "下一个缓冲区",
  -- 预览缓冲区跳转（[<C-T> ]<C-T>）
  [":ptprevious"] = "上一个预览缓冲区",
  [":ptnext"] = "下一个预览缓冲区",
  -- 标签页跳转（[t ]t [T ]T）
  [":trewind"] = "回到第一个标签页",
  [":tprevious"] = "上一个标签页",
  [":tlast"] = "跳到最后一个标签页",
  [":tnext"] = "下一个标签页",
  -- 参数文件跳转（[a ]a [A ]A，:next 等）
  [":rewind"] = "回到第一个参数文件",
  [":previous"] = "上一个参数文件",
  [":last"] = "跳到最后一个参数文件",
  [":next"] = "下一个参数文件",
  -- 位置列表跳转（[l ]l [L ]L [<C-L> ]<C-L>）
  [":lrewind"] = "回到位置列表第一条",
  [":lprevious"] = "上一个位置列表条目",
  [":llast"] = "位置列表最后一条",
  [":lnext"] = "下一个位置列表条目",
  [":lpfile"] = "跳到上一个位置列表文件",
  [":lnfile"] = "跳到下一个位置列表文件",
  -- 错误列表跳转（[q ]q [Q ]Q [<C-Q> ]<C-Q>）
  [":crewind"] = "回到错误列表第一条",
  [":cprevious"] = "上一个错误列表条目",
  [":clast"] = "错误列表最后一条",
  [":cnext"] = "下一个错误列表条目",
  [":cpfile"] = "跳到上一个错误列表文件",
  [":cnfile"] = "跳到下一个错误列表文件",

  -- LSP 自动注册的默认映射（gO / gr* / grt 等）
  ["vim.lsp.buf.document_symbol()"] = "文档符号大纲",
  ["vim.lsp.buf.type_definition()"] = "跳转到类型定义",
  ["vim.lsp.buf.implementation()"] = "跳转到实现",
  ["vim.lsp.buf.references()"] = "查找引用",
  ["vim.lsp.buf.rename()"] = "重命名符号",
  ["vim.lsp.buf.code_action()"] = "代码操作",
  ["vim.lsp.codelens.run()"] = "运行 CodeLens",
  ["vim.lsp.buf.signature_help()"] = "函数签名帮助",

  -- 补全/片段跳转（cmp 或 snippet 的 Tab 键）
  ["vim.snippet.jump if active, otherwise <Tab>"] = "片段跳转或缩进",
  ["vim.snippet.jump if active, otherwise <S-Tab>"] = "片段跳转（反向）或反缩进",

  -- Treesitter 节点选择（textobjects：an/in/[n/]n 等）
  ["Select previous sibling node"] = "选择上一个兄弟节点",
  ["Select previous node"] = "选择上一个节点",
  ["Select next sibling node"] = "选择下一个兄弟节点",
  ["Select next node"] = "选择下一个节点",
  ["Select parent (outer) node"] = "选择父（外层）节点",
  ["Select child (inner) node"] = "选择子（内层）节点",
}

-- 覆盖单个 keymap 的 desc（支持全局与 buffer-local）
local function translate(mode, km, bufnr)
  local desc = km.desc
  if not desc or not zh[desc] then return end
  local opts = {
    desc = zh[desc],
    expr = km.expr == 1,
    noremap = km.noremap == 1,
    silent = km.silent == 1,
    nowait = km.nowait == 1,
  }
  if bufnr then opts.buffer = bufnr end
  -- 原映射是 Lua 函数则沿用函数，否则沿用命令字符串；
  -- 同时保留 expr/noremap/silent/nowait 等属性，只替换 desc
  pcall(vim.keymap.set, mode, km.lhs,
    (type(km.callback) == "function") and km.callback or km.rhs, opts)
end

-- 扫描当前所有已注册的 keymap（全局 + buffer-local），把英文 desc 替换成中文
local function apply()
  -- 全局 keymap（五种模式 + 命令行/终端）
  for _, mode in ipairs({ "n", "v", "o", "i", "c", "t" }) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      translate(mode, km)
    end
    -- buffer-local keymap：telescope / trouble / cmp 等浮窗插件的按键
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
        translate(mode, km, buf)
      end
    end
  end
end

-- 立即执行一次：覆盖 nvim 内置 + 已加载插件的英文 desc
apply()

-- 插件大多按需（懒）加载，且 LSP 在打开文件后才会 attach（此时才注册 gr*/gO 等键）。
-- 因此在多个后续事件上重复执行，确保新注册的映射英文 desc 都被补上中文
local group = vim.api.nvim_create_augroup("KeymapZh", { clear = true })
for _, event in ipairs({
  "VimEnter",      -- 启动完成
  "BufReadPre",    -- 打开文件（读入前）
  "BufNewFile",    -- 新建文件
  "FileType",      -- 文件类型确定（插件常在此注册按键）
  "LspAttach",     -- LSP 连接（注册 gr*/gO/grn 等）
  "TermOpen",      -- 打开终端 buffer
}) do
  vim.api.nvim_create_autocmd(event, { group = group, callback = apply })
end

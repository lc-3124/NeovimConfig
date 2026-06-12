# Neovim 配置使用手册

## 目录结构

```
nvim/
├── init.lua                 # 入口：引导 lazy.nvim → 导入插件 → 加载核心配置
├── lazy-lock.json           # 插件版本锁定（自动维护）
├── avante.md                # Avante AI 项目级指令（可选）
└── lua/
    ├── core/                # 非插件配置
    │   ├── options.lua      # 编辑器选项
    │   ├── keymaps.lua      # 全局快捷键
    │   ├── autocmds.lua     # 自动命令（fcitx5 输入法、光标恢复）
    │   └── colorscheme.lua  # 颜色主题（tokyonight）
    └── plugins/             # 插件配置（lazy.nvim 自动加载）
        ├── avante.lua       # AI 编程助手
        ├── barbecue.lua     # 面包屑导航栏
        ├── bufferline.lua   # 缓冲区标签栏
        ├── cmp.lua          # 自动补全 + 代码片段 + 函数签名
        ├── colorscheme.lua  # tokyonight 主题配置
        ├── fidget.lua       # LSP 进度通知
        ├── gitsigns.lua     # Git 行内改动标记
        ├── indent.lua       # 缩进参考线
        ├── lsp.lua          # LSP 配置 + Mason 安装器
        ├── lualine.lua      # 状态栏
        ├── nvimtree.lua     # 文件树
        ├── snacks.lua       # 增强工具集（通知、状态列等）
        ├── tabset.lua       # 按文件类型缩进 + 自动括号
        ├── telescope.lua    # 模糊搜索
        ├── todo-comments.lua# TODO/FIXME 高亮
        ├── trouble.lua      # 诊断/符号面板
        └── whichkey.lua     # 快捷键提示
```

---

## 初次启动

1. 打开 Neovim：`nvim`
2. lazy.nvim 会自动安装所有插件
3. 执行 `:checkhealth` 确认各项状态正常
4. 执行 `:Mason` 查看已安装/待安装的 LSP 服务器

### 可能需要的外部依赖

| 工具 | 用途 | 安装方式 |
|---|---|---|
| ripgrep | Telescope live_grep | `sudo apt install ripgrep` |
| fd-find | Telescope find_files | `sudo apt install fd-find` |
| make | 编译插件（telescope-fzf） | `sudo apt install build-essential` |
| cargo | 编译 avante.nvim（可选） | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |

---

## 核心快捷键

| 快捷键 | 模式 | 功能 |
|---|---|---|
| `\` | - | Leader 键（默认） |
| `<S-j>` | Normal | 向下翻半页 |
| `<S-k>` | Normal | 向上翻半页 |
| `<Leader> w` | Normal | 保存文件 |
| `<Leader> q` | Normal | 关闭当前窗口 |

### LSP 快捷键（文件打开后自动启用）

| 快捷键 | 功能 |
|---|---|
| `gd` | 跳转到定义 |
| `K` | 悬停显示文档 |
| `gi` | 跳转到实现 |
| `gr` | 查找引用 |
| `<Leader> rn` | 重命名符号 |
| `<Leader> ca` | 代码操作 |
| `<Leader> f` | 格式化代码 |
| `<Leader> lh` | 切换 inlay hints（类型提示） |

### Telescope

| 快捷键 | 功能 |
|---|---|
| `<Leader> ff` | 查找文件 |
| `<Leader> fg` | 全文搜索（live_grep） |
| `<Leader> fb` | 切换缓冲区 |
| `<Leader> fh` | 搜索帮助文档 |

### NvimTree

| 快捷键 | 功能 |
|---|---|
| `<F3>` | 切换文件树 |

### 文档符号树（Trouble）

| 快捷键 | 功能 |
|---|---|
| `<Leader> cs` | 打开当前文件的符号树（类/函数/变量等） |
| `<Leader> cl` | LSP 引用/定义面板 |
| `<Leader> xx` | 全项目诊断列表 |
| `<Leader> xX` | 当前文件诊断 |

符号树通过 LSP 的 `textDocument/documentSymbol` 获取数据，由 `trouble.nvim` 渲染。
右侧面板显示，可浏览、跳转和搜索。在 trouble 窗口中按 `?` 查看快捷键帮助。

### Bufferline

| 快捷键 | 功能 |
|---|---|
| `<Tab>` | 下一个缓冲区 |
| `<S-Tab>` | 上一个缓冲区 |

---

## Avante AI 使用

### 环境变量

```bash
# DeepSeek API（当前默认提供商）
export DEEPSEEK_API_KEY="sk-xxx"

# 可选：作用域隔离的 API key（推荐）
export AVANTE_DEEPSEEK_API_KEY="sk-xxx"

# Web 搜索（可选）
export TAVILY_API_KEY="tvly-xxx"
```

### 基本命令

| 命令 | 功能 |
|---|---|
| `:AvanteAsk` | 向 AI 提问当前代码 |
| `:AvanteSwitchProvider` | 切换 AI 提供商 |
| `:AvanteClear` | 清除对话历史 |

### 项目级指令

在项目根目录创建 `avante.md` 文件，AI 会自动读取其中的指令。已默认启用 `instructions_file = "avante.md"`。

---

## 注意事项

### 1. `<Tab>` 与 `<C-I>` 冲突

`<Tab>` 在终端中等价于 `<C-I>`（`<C-I>` 是 Normal 模式的跳转列表前进）。如果 `<Tab>` 快捷键冲突，可以考虑改用其他键或自行调整 bufferline 配置。

### 2. fcitx5 输入法

如果系统不使用 fcitx5 输入法，autocmds.lua 中的 fcitx5 相关代码会自动跳过（检测 `fcitx5-remote` 命令是否存在）。无影响。

### 3. 主题配置

当前使用 `tokyonight.nvim`，`style = "storm"`。可修改 `lua/plugins/colorscheme.lua` 中的 `style` 选项：
- `"storm"`（当前，蓝灰调）
- `"moon"`（暖灰调，默认）
- `"night"`（更暗）
- `"day"`（浅色）

同时修改 `lua/core/colorscheme.lua` 中的 `colorscheme` 命令。

主题自动适配 lualine、bufferline、nvim-tree、telescope、which-key 等所有插件。

### 4. 插件同步

任何时候执行 `:Lazy sync` 可同步插件版本（lazy-lock.json 自动更新）。

### 5. LSP 自动安装

Mason 配置了 5 个 LSP 服务器的自动安装：
- `lua_ls`（Lua）
- `clangd`（C/C++）
- `pyright`（Python）
- `rust_analyzer`（Rust）
- `ts_ls`（TypeScript/JavaScript）

如需添加更多，编辑 `lua/plugins/lsp.lua` 中的 `ensure_installed` 列表。

### 6. 语法高亮（无 treesitter）

本配置已移除 `nvim-treesitter`（兼容性问题），使用 Neovim 内置的 `:syntax on` 正则高亮。
对 C/Python/Lua/Markdown 等常用语言效果足够。不再需要管理 treesitter 解析器。

### 7. Git 行内标记

已安装 `gitsigns.nvim`，在行号旁显示增删改标记。快捷键：
| 快捷键 | 功能 |
|---|---|
| `]c` / `[c` | 下一处/上一处改动 |
| `<leader> gs` | 暂存 hunk |
| `<leader> gr` | 重置 hunk |
| `<leader> gp` | 预览改动 |
| `<leader> gb` | Blame 当前行 |
| `<leader> gd` | 对比当前文件 |

### 8. TODO/FIXME 高亮

已安装 `todo-comments.nvim` 高亮注释中的 TODO/FIXME/HACK/WARN 等关键词。
使用 `:TodoTelescope` 搜索所有 TODO 注释。

### 9. 诊断/符号面板

已安装 `trouble.nvim`。快捷键：
| 快捷键 | 功能 |
|---|---|
| `<leader> xx` | 诊断列表 |
| `<leader> xX` | 当前文件诊断 |
| `<leader> cs` | 文档符号树 |
| `<leader> cl` | LSP 引用/定义 |
| `<leader> xL` | Location List |
| `<leader> xQ` | Quickfix List |

### 10. Telescope fzf 原生排序

已添加 `telescope-fzf-native.nvim` 扩展，需 `make` 编译。如没有 `make` 工具，Telescope 会降级使用 Lua 排序器，不影响使用。

### 11. fidget 进度图标

如果进度图标显示异常，将 `lua/plugins/fidget.lua` 中的 `progress_icon` 改为：
```lua
progress_icon = "dots",
```
（不带 table 包裹的字符串格式）

### 12. snacks 状态列

`snacks.statuscolumn` 已启用，替代了内置的 statuscolumn 和 nvim-scrollbar。默认配置即可使用，无需额外设置。

### 13. 💫 动画和平滑滚动是怎么实现的？

两个 `snacks.nvim` 组件：

- **`snacks.animate`**：为 `scroll`、`win`、`cursor`、`fold` 等操作添加缓动动画（45+ 种缓动函数）。例如滚动到某处不是瞬移而是平滑移动。
- **`snacks.scroll`**：替换 Neovim 默认的瞬间滚动，改为平滑滚动效果。

在 `lua/plugins/snacks.lua` 中各自一行 `enabled = true` 即可启用，无需额外配置。如果想调整动画风格，可以传更多参数：

```lua
animate = {
  enabled = true,
  easing = "ease_out_quad",  -- 缓动函数，可换成 ease_out_cubic 等
  fps = 60,
},
```

底层原理：`snacks.animate` 用 `vim.schedule` + `vim.loop.timer` 驱动逐帧渲染，每帧更新窗口位置或滚动偏移，利用 Neovim 的 `win_float` API 和 pum（弹出菜单）动画 Hook 实现流畅动画。

### 14. 窗口导航建议

当前未配置 `<C-h/j/k/l>` 窗口导航快捷键。如需添加，编辑 `lua/core/keymaps.lua`：
```lua
map("n", "<C-h>", "<C-w>h", { desc = "左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右窗口" })
```

---

## 编程指导

### 补全使用

| 操作 | 效果 |
|---|---|
| 输入时自动弹出 | 自动补全建议 |
| `<Tab>` | 选中下一个补全项 / 展开 snippet |
| `<S-Tab>` | 选中上一个补全项 / 跳转 snippet 占位符 |
| `<CR>` | 确认选中 |
| `<C-Space>` | 手动触发补全 |
| `<C-e>` | 关闭补全浮窗 |
| `<C-b>` / `<C-f>` | 滚动补全文档 |
| `<C-s>` | 切换函数签名提示 |

### 代码导航

- `gd` 跳转定义 → 想看 `:Telescope lsp_definitions` 列出多个定义
- `gr` 查找引用 → 按 `<leader> xx` 用 trouble 面板浏览
- `K` 悬浮文档 → 再按一次关闭
- `[c` / `]c` 在 Git 改动间跳转
- `<leader> lh` 开关类型提示（inlay hints）

### 常见编码流程

```
1. 打开项目：nvim .
2. 按 <F3> 打开文件树浏览
3. <leader> ff 搜索文件
4. 编辑代码（Tab 补全、autopairs 自动括号）
5. <leader> f 格式化代码
6. gd 跳转定义，gr 查看引用
7. <leader> gs 暂存 hunk，:G commit 提交
```

### 诊断处理

- `<leader> xx` — 打开诊断面板（所有文件）
- `<leader> xX` — 当前文件诊断
- trouble 面板中按 `?` 查看快捷键帮助
- 按 `o` / `<CR>` 跳转到错误位置，`q` 关闭面板

---

## 常见问题排查

### `:checkhealth` 显示错误

按提示逐一修复。常见问题：
- `ripgrep` 未安装 → `sudo apt install ripgrep`
- `fd` 未安装 → `sudo apt install fd-find`
- 终端不支持真彩色 → 确认 `$TERM` 设为 `xterm-256color` 或使用 kitty/alacritty/ghostty

### 插件加载失败

```vim
:Lazy log    " 查看错误日志
:Lazy clean  " 清理未使用的插件
:Lazy sync   " 重新同步
```

### 颜色显示异常

确保：
1. `vim.opt.termguicolors = true`（已在 options.lua 设置）
2. 终端模拟器支持真彩色
3. 使用 Nerd Font（推荐 Hack Nerd Font 或 JetBrains Mono Nerd Font）

---

*最后更新: 2026-06-12*
*配置文件路径: `~/.config/nvim/`*

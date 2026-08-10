# Neovim 配置

```
nvim/
├── init.lua                  # 入口：引导 lazy.nvim → 导入插件 → 加载核心配置
├── avante.md                 # Avante AI 项目级指令（可选）
└── lua/
    ├── core/                 # 非插件配置（不依赖 lazy.nvim）
    │   ├── options.lua       # 编辑器选项
    │   ├── keymaps.lua       # 全局快捷键
    │   ├── autocmds.lua      # 自动命令（fcitx5 输入法、光标恢复）
    │   ├── colorscheme.lua   # 颜色主题（tokyonight）
    │   └── treesitter.lua    # 内置 treesitter + :TSInstall 命令
    └── plugins/              # 插件配置（lazy.nvim 自动加载）
        ├── colorscheme.lua   # tokyonight 主题配置
        ├── commentary.lua    # 快速逐行注释（gc/gcc）
        ├── lsp.lua           # LSP 配置 + Mason 安装器
        ├── cmp.lua           # 自动补全 + 代码片段 + 自动括号
        ├── telescope.lua     # 模糊搜索
        ├── lualine.lua       # 状态栏
        ├── bufferline.lua    # 缓冲区标签栏
        ├── whichkey.lua      # 快捷键提示（v3）
        ├── gitsigns.lua      # Git 行内改动标记
        ├── snacks.lua        # UI 增强套件（dashboard/dim/indent/notifier…）
        ├── noice.lua         # 命令行美化
        ├── trouble.lua       # 诊断/符号面板
        ├── todo-comments.lua # TODO/FIXME 高亮
        ├── avante.lua        # AI 编程助手（deepseek）
        ├── nvimtree.lua      # 文件树
        └── barbecue.lua      # 面包屑导航栏
```

## 核心快捷键

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `\` | - | Leader 键 |
| `<S-j>` | Normal | 向下翻半页 |
| `<S-k>` | Normal | 向上翻半页 |
| `<Leader> w` | Normal | 保存文件 |
| `<Leader> q` | Normal | 关闭当前窗口 |
| `<Leader> ya` | Normal | 复制整个文件到系统剪贴板 |
| `<Leader> y` | Visual | 复制选中内容到系统剪贴板 |
| `<Leader> dd` | Normal | 打开 Dashboard |
| `<Leader> bd` | Normal | 删除当前缓冲区 |
| `<Leader> un` | Normal | 关闭通知 |
| `<Leader> n` | Normal | 通知历史 |

### 快速逐行注释（vim-commentary）

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gc` | Visual | **选择多行后按 `gc`，逐行注释 / 取消注释** |
| `gcc` | Normal | 注释 / 取消注释当前行 |
| `gc` + 移动 | Normal | 如 `gc2j` 注释光标起下面两行 |

再次执行相同操作会取消注释（切换式）。

### LSP（文件打开后自动启用）

| 快捷键 | 功能 |
|--------|------|
| `gh` | LSP 语法帮助（hover） |
| `gd` | 跳转到定义 |
| `gi` | 跳转到实现 |
| `gr` | 查找引用 |
| `<Leader> rn` | 重命名符号 |
| `<Leader> ca` | 代码操作 |
| `<Leader> f` | 格式化代码 |
| `<Leader> lh` | 切换 inlay hints（类型提示） |

注：`K`（Shift+K）**未绑定 LSP hover**，保留为翻半页。

### Telescope

| 快捷键 | 功能 |
|--------|------|
| `<Leader> ff` | 查找文件 |
| `<Leader> fg` | 全文搜索（live_grep） |
| `<Leader> fb` | 切换缓冲区 |
| `<Leader> fh` | 搜索帮助文档 |

### Bufferline

| 快捷键 | 功能 |
|--------|------|
| `<Tab>` | 下一个缓冲区 |
| `<S-Tab>` | 上一个缓冲区 |

### NvimTree

| 快捷键 | 功能 |
|--------|------|
| `<F3>` | 切换文件树 |

### Trouble（诊断/符号面板）

| 快捷键 | 功能 |
|--------|------|
| `<Leader> xx` | 全项目诊断列表 |
| `<Leader> xX` | 当前文件诊断 |
| `<Leader> cs` | 文档符号树 |
| `<Leader> cl` | LSP 引用/定义 |
| `<Leader> xL` | Location List |
| `<Leader> xQ` | Quickfix List |

### Git（gitsigns）

| 快捷键 | 功能 |
|--------|------|
| `]c` | 下一处改动 |
| `[c` | 上一处改动 |
| `<Leader> gs` | 暂存 hunk |
| `<Leader> gr` | 重置 hunk |
| `<Leader> gS` | 暂存整个文件 |
| `<Leader> gu` | 撤销暂存 |
| `<Leader> gR` | 重置文件 |
| `<Leader> gp` | 预览改动 |
| `<Leader> gb` | Blame 当前行 |
| `<Leader> gB` | Buffer Blame |
| `<Leader> gd` | 对比当前文件 |
| `<Leader> gD` | 对比上次提交 |
| `<Leader> gt` | 切换标记显示 |
| `<Leader> gT` | 切换行内 Blame |

### 补全（nvim-cmp）

| 操作 | 效果 |
|------|------|
| 输入时自动弹出 | 自动补全建议 |
| `<Tab>` | 选中下一个补全项 / 展开 snippet |
| `<S-Tab>` | 选中上一个 / 跳转 snippet 占位符 |
| `<CR>` | 确认选中 |
| `<C-Space>` | 手动触发补全 |
| `<C-e>` | 关闭补全浮窗 |
| `<C-b>` / `<C-f>` | 滚动补全文档 |
| `<C-s>` | 切换函数签名提示 |

## 初次启动

1. 打开 Neovim：`nvim`
2. lazy.nvim 会自动安装所有插件
3. 执行 `:checkhealth` 确认状态
4. 执行 `:Mason` 查看 LSP 服务器

### 外部依赖

| 工具 | 用途 | 安装 |
|------|------|------|
| ripgrep | Telescope live_grep | `sudo pacman -S ripgrep` |
| fd | Telescope find_files | `sudo pacman -S fd` |
| make | 编译插件 | `sudo pacman -S base-devel` |
| cargo | avante.nvim 编译（可选） | `sudo pacman -S rust` |
| curl | TSInstall 下载查询文件 | `sudo pacman -S curl` |

## Avante AI

### 环境变量

```bash
export DEEPSEEK_API_KEY="sk-xxx"
export TAVILY_API_KEY="tvly-xxx"
```

### 命令

| 命令 | 功能 |
|------|------|
| `:AvanteAsk` | 向 AI 提问当前代码 |
| `:AvanteSwitchProvider` | 切换 AI 提供商 |
| `:AvanteClear` | 清除对话历史 |

## Treesitter 语法高亮

本配置使用 **Neovim 0.12 内置 treesitter**，不依赖已归档的 `nvim-treesitter` 插件。

### TSInstall 命令

安装 parser：
```
:TSInstall make
:TSInstall markdown
```

安装后自动从 nvim-treesitter 仓库下载对应的 highlight 查询文件。

### 已预装 parser

`make` `markdown` `markdown_inline` `lua` `vim` `vimdoc` `c` `python` `json` `yaml` `toml` `html` `css` `javascript` `typescript` `rust`

如需更多，`:TSInstall <语言>` 即可（有 Tab 补全）。

### 注意事项

- Makefile 的 highlight 查询文件需从 nvim-treesitter 仓库下载（Neovim 0.12 无内置 make 查询）
- treesitter 启动失败时自动回退到正则高亮
- **没有安装任何 markdown 渲染插件**（如 render-markdown.nvim），markdown 以纯文本方式显示，但语法高亮正常

## 插件说明

### snacks.nvim（核心 UI 套件）

用单插件取代了多个独立插件：

| 模块 | 取代 |
|------|------|
| `indent` | indent-blankline.nvim |
| `input` | dressing.nvim（vim.ui.input） |
| `notifier` | fidget.nvim 通知部分 |
| `dashboard` | 独立 dashboard 插件 |
| `statuscolumn` | 内置状态列增强 |

其他启用模块：`bigfile`、`words`、`animate`、`scroll`、`quickfile`、`scope`、`dim`

### noice.nvim

替换默认命令行界面为浮动窗口，带图标和语法高亮。`:Noice` 查看历史。

### which-key v3

使用新版 API（`opts.spec` + `wk.add()`），preset 设为 `helix` 风格。

## 注意事项

### 1. `<Tab>` 与 `<C-I>` 冲突

`<Tab>` 在终端中等价于 `<C-I>`（跳转列表前进）。如果冲突，可调整 bufferline 配置。

### 2. fcitx5 输入法

autocmds.lua 中自动检测 `fcitx5-remote` 是否存在，不存在则跳过。

### 3. 主题切换

当前 `tokyonight` `style = "storm"`。可选：`storm`、`moon`、`night`、`day`。
需同步修改 `lua/core/colorscheme.lua` 中的 `colorscheme` 命令。

### 4. LSP 自动安装

Mason 预配置 5 个 LSP：`lua_ls` `clangd` `pyright` `rust_analyzer` `ts_ls`。
编辑 `lua/plugins/lsp.lua` 中 `ensure_installed` 列表可增减。

### 5. vim.lsp.with() 废弃

已在 `lsp.lua` 中替换为标准函数包装，消除 Neovim 0.12 废弃警告。

### 6. 窗口导航

未配置 `<C-h/j/k/l>` 窗口导航。如需，加到 `core/keymaps.lua`：
```lua
map("n", "<C-h>", "<C-w>h", { desc = "左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右窗口" })
```

### 7. 常见排查

```vim
:checkhealth    " 运行健康检查
:Lazy log       " 查看插件加载日志
:Lazy clean     " 清理未使用插件
:Lazy sync      " 重新同步所有插件
:Noice log      " 查看 noice 日志
```

---

## Hyprland 快捷键列表

快捷键列表通过 `keybinds.sh` 脚本自动生成，用 fuzzel 展示。调用方式：`SUPER + H`

### 注释约定

`keybind.lua` 中，在 `hl.bind()` 上方紧邻的 `--` 注释行被脚本提取作为快捷键说明：

```lua
-- 打开终端
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
-- 关闭窗口
hl.bind(mainMod .. " + C", hl.dsp.window.close())
```

规则：
- 注释必须紧贴在 `hl.bind()` 上方，中间不能有空行
- 注释以 `-- ` 开头，之后的内容直接作为说明文本
- 没有注释的行会尝试从 API 调用自动生成说明
- 鼠标、多媒体键（XF86）、F 功能键和 Print 键被过滤不显示
- `for` 循环自动展开，只需在循环体外的单条 `hl.bind()`（如 `SUPER + 0`）上方写注释即可

### 添加新快捷键

```lua
-- 你的说明文字
hl.bind("SUPER + K", hl.dsp.exec_cmd("your-command"))
```

添加后按 `SUPER + H` 即可看到新快捷键出现在列表中。

---

*最后更新: 2026-07-27*

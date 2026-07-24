# Neovim 配置项目

这是一个 Neovim 配置文件仓库，使用 lazy.nvim 管理插件。

## 技术栈

- Neovim 配置语言：Lua
- 插件管理器：folke/lazy.nvim
- 主题：folke/tokyonight.nvim (storm)
- LSP：nvim-lspconfig + mason.nvim
- 补全：nvim-cmp + LuaSnip
- AI 助手：yetone/avante.nvim

## 配置结构

- `init.lua` - 入口
- `lua/core/` - 非插件配置（选项、快捷键、自动命令、主题）
- `lua/plugins/` - 插件配置

## 注意事项

- 快捷键使用 `\` 作为 leader 键
- 不要修改 lazy-lock.json 的锁版本
- API keys 通过环境变量设置（DEEPSEEK_API_KEY、TAVILY_API_KEY）

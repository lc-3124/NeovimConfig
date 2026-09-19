-- ============================================================================
-- 插件：avante.nvim（编辑器内 AI 助手）
-- 作用：在 Neovim 里直接和 AI 对话/改代码，类似 Cursor 的体验。
-- 这里配置使用 DeepSeek 作为后端模型。
-- 注意：API 密钥通过环境变量 DEEPSEEK_API_KEY 提供，不要写死在配置里。
-- ============================================================================
return {
  {
    "yetone/avante.nvim",
    build = "make",             -- 安装时执行 make 编译原生部分
    event = "VeryLazy",         -- 启动后期再加载
    version = false,            -- 不锁定版本，跟随最新提交
    dependencies = {
      "nvim-lua/plenary.nvim",          -- 通用工具库
      "MunifTanjim/nui.nvim",           -- UI 组件库
      "nvim-telescope/telescope.nvim",  -- 选择器（用于选文件等）
      "hrsh7th/nvim-cmp",               -- 补全引擎（AI 补全候选）
      "nvim-tree/nvim-web-devicons",    -- 图标
    },
    opts = {
      provider = "deepseek",            -- 默认使用的模型提供商
      disable_thinking = true,          -- 关闭"思考"流程（DeepSeek 快速应答）
      input_provider = "snacks",        -- 输入框用 snacks 的输入
      select_provider = "snacks",       -- 选择器用 snacks
      enable_default_tools = true,      -- 启用默认工具栏（文件操作等）
      instructions_file = "avante.md",  -- 项目级自定义指令文件
      web_search_engine = {             -- 联网搜索（用于需要查资料时）
        provider = "tavily",
        api_key = os.getenv("TAVILY_API_KEY"),  -- 密钥从环境变量读
        include_answer = true,
      },
      providers = {
        -- DeepSeek 提供商配置（继承 OpenAI 兼容协议）
        deepseek = {
          __inherited_from = "openai",                -- 复用 openai 的请求逻辑
          endpoint = "https://api.deepseek.com/v1",   -- DeepSeek API 地址
          model = "deepseek-v4-flash",                -- 使用模型名
          api_key_name = "DEEPSEEK_API_KEY",          -- 读取该环境变量作为密钥
          timeout = 30000,                            -- 请求超时 30 秒
        },
      },
      behaviour = {
        auto_suggestions = false,        -- 关闭自动建议（避免打扰）
        enable_cursor_planning = true,   -- 允许 AI 进行光标移动规划
      },
    },
  },
}

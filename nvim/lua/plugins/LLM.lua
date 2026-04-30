return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
  and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  or "make",
  event = "VeryLazy",
  opts = {
    -- 设置默认使用的 provider 为 dashscope
    provider = "dashscope",
    providers = {
      -- 添加 DashScope（阿里云百炼）作为自定义 provider
      dashscope = {
        __inherited_from = "openai", -- 关键：继承 OpenAI 的基础实现
        endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
        model = "qwen3-coder-plus",                -- 可替换为 qwen-max、qwen-turbo 等
        api_key_name = "DASHSCOPE_API_KEY", -- 插件会自动读取该环境变量
        timeout = 30000,                     -- 超时时间（毫秒）
        -- 可选：添加额外请求体参数
        extra_request_body = {
          system = "你是一个专业的AI助手，严格遵守以下规则：\n1. 始终使用中文回答所有问题\n2.当用户问题不包含 '\\do'指令 时，只能描述修改方案，不能执行真实文件修改\n3. 所有回答必须清晰、准确、专业",
          temperature = 0.7,
        },
      },
      -- 【新增】配置web search，读取环境变量的Tavily Key
      web_search = {
        provider = "tavily",          -- 指定搜索引擎为tavily
        api_key = os.getenv("TAVILY_API_KEY"), -- 环境变量
        enabled = true,               -- 开启网页搜索功能
        fallback = true               -- 搜索失败时用本地知识库兜底
      },

      -- 暂存-确认-写入'的工作流，
      preview_on_edit = true,
      confirm_on_edit = true,
      -- 如果你还需要保留其他 provider（如 OpenAI、Claude），可以继续添加
    },
    -- 其他 avante 配置选项...
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- 以下为可选依赖，按需添加
    "nvim-telescope/telescope.nvim",   -- 用于文件选择器
    "hrsh7th/nvim-cmp",                 -- 自动补全
    "stevearc/dressing.nvim",           -- 输入 UI 优化
    "nvim-tree/nvim-web-devicons",      -- 图标
    -- 支持粘贴图片（可选）
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    -- 渲染 Markdown（可选）
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
}

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
        model = "qwen-plus",                -- 可替换为 qwen-max、qwen-turbo 等
        api_key_name = "DASHSCOPE_API_KEY", -- 插件会自动读取该环境变量
        timeout = 30000,                     -- 超时时间（毫秒）
        -- 可选：添加额外请求体参数
        -- extra_request_body = {
        --   temperature = 0.7,
        --   max_tokens = 4096,
        -- },
      },
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

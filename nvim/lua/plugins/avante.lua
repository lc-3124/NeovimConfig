return {
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      provider = "deepseek",
      disable_thinking = true,
      input_provider = "snacks",
      select_provider = "snacks",
      enable_default_tools = true,
      instructions_file = "avante.md",
      web_search_engine = {
        provider = "tavily",
        api_key = os.getenv("TAVILY_API_KEY"),
        include_answer = true,
      },
      providers = {
        deepseek = {
          __inherited_from = "openai",
          endpoint = "https://api.deepseek.com/v1",
          model = "deepseek-v4-flash",
          api_key_name = "DEEPSEEK_API_KEY",
          timeout = 30000,
        },
      },
      behaviour = {
        auto_suggestions = false,
        enable_cursor_planning = true,
      },
    },
  },
}

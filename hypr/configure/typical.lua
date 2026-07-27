-- ============================================================================
-- 应用程序专属窗口规则模块
-- ============================================================================
-- hl.window_rule({
--   name  = "规则名",            -- 可选，用于动态启用/禁用
--   match = { class/title/... }, -- 匹配条件（class / title / xwayland / float ...）
--   -- 静态效果（设一次就固定）：
--   float / tile / fullscreen / move / size / center / workspace / pin / ...
--   -- 动态效果（持续生效）：
--   opacity / no_focus / no_blur / no_shadow / border_color / ...
-- })
-- ============================================================================

-- 全局规则：忽略最大化请求 ------------------------------------------------
-- 所有窗口都不允许最大化，窗口行为统一由平铺管理器控制
hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- XWayland 拖拽/焦点修复 -------------------------------------------------
-- XWayland 应用（如 Wine）在浮动且非全屏时可能出现拖拽或焦点异常
-- 此规则匹配这些条件但不做任何操作，仅作标记（依赖 hyprland 内部行为）
hl.window_rule({
  name = "fix-xwayland-drag",
  match = {
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
})

-- Kitty 终端浮动模式 ------------------------------------------------------
-- 以浮动窗口启动 Kitty，默认 1650x880 居中，透明度 0.85
-- 适合作为临时编辑器、参考文档阅读器等场景
hl.window_rule({
  name = "kitty-float",
  match = { class = "^(kitty)$" },
  float = true,
  size = "1650 880",
  center = true,
  opacity = "0.85",
})

-- Kitty 透明度（第二个规则，可单独启用/禁用）-------------------------------
hl.window_rule({
  name = "kitty-opacity",
  match = { class = "^(kitty)$" },
})

-- 测试/示例窗口浮动 -------------------------------------------------------
-- 标题含有 "_demo_or_test" 的窗口自动浮动
hl.window_rule({
  name = "dev-float",
  match = { title = ".*_demo_or_test.*" },
  float = true,
})

-- Steam 浮动居中 ----------------------------------------------------------
hl.window_rule({
  name = "steam-float",
  match = { class = ".*steam.*" },
  float = true,
  center = true,
})

-- AnyTalk 语音输入浮层 ----------------------------------------------------
-- fcitx5-anytalk 的语音识别浮层：浮动、不抢占焦点、固定位置
hl.window_rule({
  name = "anytalk-float",
  match = { class = "^(anytalk-overlay)$" },
  float = true,
  no_focus = true,
  move = "660 960",
})

-- Waybar 状态栏 -----------------------------------------------------------
-- 设为浮动（但 waybar 通常是 layer-shell，此规则作为兜底）
hl.window_rule({
  name = "waybar-float",
  match = { class = "Waybar" },
  float = true,
})

-- Wine 窗口浮动 -----------------------------------------------------------
hl.window_rule({
  name = "wine-float",
  match = { class = "^(wine|Wine|.*\\.[Ee][Xx][Ee])$" },
  float = true,
})

-- Dunst 通知 --------------------------------------------------------------
-- 通知弹窗设透明度
hl.window_rule({
  name = "dunst-blur",
  match = { class = "^(dunst)$" },
  opacity = "0.85",
})

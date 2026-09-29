-- ============================================================================
-- 外观 & 基础设置模块
-- ============================================================================
-- 涵盖 general / decoration / animations / input / gestures / 布局 / misc / xwayland
-- ============================================================================

hl.config({
  -- 通用设置 ----------------------------------------------------------------
  general = {
    gaps_in = 8,
    gaps_out = 8,
    border_size = 2,
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  -- 装饰设置 ----------------------------------------------------------------
  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1,
    inactive_opacity = 1,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 2,
      passes = 2,
      vibrancy = 0.1696,
    },
  },

  -- 动画设置（仅启用开关，曲线和具体动画定义在下方顶层调用）-----------------
  animations = {
    enabled = true,
    workspace_wraparound = true,   -- 跨工作区滑动：1→2→…→10→1 循环
  },

  -- 输入设置 ----------------------------------------------------------------
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    -- sensitivity = -0.40,
     sensitivity = 0.2,
    touchpad = {
      disable_while_typing = false,
      natural_scroll = false,
      tap_to_click = true,
    },
  },

  -- 手势配置选项：下方 hl.gesture() 中定义具体手势动作

  -- 窗口布局 ----------------------------------------------------------------
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },

  -- 杂项 ----------------------------------------------------------------
  misc = {
    disable_splash_rendering = true,
    focus_on_activate = true,
    disable_hyprland_logo = true,
    force_default_wallpaper = 0,
    font_family = "JBMBold",  -- 粗体：JetBrainsMono Nerd Font Bold（fontconfig 别名）
  },

  -- XWayland 设置 -----------------------------------------------------------
  xwayland = {
    force_zero_scaling = true,
  },
})

-- 贝塞尔曲线定义 ------------------------------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- 弹簧曲线（"力量感"）：高速逼近 → 急停 → 少许余振
--   stiffness 越大越快（时段越短）；dampening 越大余振越少、停得越利落；mass 越大越沉
--   （弹簧动画里 speed 无效，长短由 stiffness/mass 决定）
hl.curve("snap", { type = "spring", mass = 1, stiffness = 700, dampening = 42 })
-- 窗口弹出/消失弹簧：ζ≈0.64（可见一下回弹），整体时长约为上一版 0.8×
hl.curve("pop",  { type = "spring", mass = 1, stiffness = 1200, dampening = 44 })

-- 动画定义 ------------------------------------------------------------------
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
-- 窗口：召唤 = 从所在区域中心放大弹出（含蓄，popin 80%）；消失 = 向中心缩小（popin 45%）+ 淡出
--       统一用同一弹簧("pop")，让"旧窗口让位缩小 + 新窗口弹出"整体协调
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "pop" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4,    spring = "pop", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 4,    spring = "pop", style = "popin 45%" })
hl.animation({ leaf = "windowsMove",   enabled = true,  speed = 4,    spring = "pop" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.6,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.6,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })

-- 工作区滑行：快 + 急停 + 余振（spring: snap）
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 4, spring = "snap", style = "slidefade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 4, spring = "snap", style = "slidefade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 3, spring = "snap", style = "slidefade" })

-- magic 草稿箱：从上方拉下来（竖向滑入）+ 余振
hl.animation({ leaf = "specialWorkspace",    enabled = true, speed = 4, spring = "snap", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 4, spring = "snap", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, spring = "snap", style = "slidevert" })

-- 旋转渐变边框（华丽；loop 会持续渲染，略耗电/影响续航）
hl.animation({ leaf = "borderangle",   enabled = true,  speed = 8,    bezier = "linear", style = "loop" })

-- 设备级输入设置 ------------------------------------------------------------
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

-- 触控板手势 ----------------------------------------------------------------
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

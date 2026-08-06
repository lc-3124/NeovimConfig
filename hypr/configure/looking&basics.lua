-- ============================================================================
-- 外观 & 基础设置模块
-- ============================================================================
-- 涵盖 general / decoration / animations / input / gestures / 布局 / misc / xwayland
-- ============================================================================

hl.config({
  -- 通用设置 ----------------------------------------------------------------
  general = {
    gaps_in = 10,
    gaps_out = 12,
    border_size = 1,
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
      size = 3,
      passes = 3,
      vibrancy = 0.1696,
    },
  },

  -- 动画设置（仅启用开关，曲线和具体动画定义在下方顶层调用）-----------------
  animations = {
    enabled = true,
  },

  -- 输入设置 ----------------------------------------------------------------
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
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
    force_default_wallpaper = -1,
    font_family = "Ubuntu Nerd Font",
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

-- 动画定义 ------------------------------------------------------------------
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })

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

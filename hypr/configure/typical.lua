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
-- 原规则名: suppress-maximize
hl.window_rule({
  name = "全局·禁止最大化",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- XWayland 拖拽/焦点修复 -------------------------------------------------
-- XWayland 应用（如 Wine）在浮动且非全屏时可能出现拖拽或焦点异常
-- 此规则匹配这些条件但不做任何操作，仅作标记（依赖 hyprland 内部行为）
-- 原规则名: fix-xwayland-drag
hl.window_rule({
  name = "XWayland·拖拽焦点修复",
  match = {
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
})

-- Kitty 终端浮动模式 ------------------------------------------------------
-- 以浮动窗口启动 Kitty，默认 1650x880 居中
-- 适合作为临时编辑器、参考文档阅读器等场景
-- 原规则名: kitty-float
 hl.window_rule({
  name = "Kitty·浮动",
  match = { class = "^(kitty)$" },
 -- float = true,
 --  size = "1650 880",
 -- center = true,
  opacity = "0.95",
})

-- Kitty 透明度（第二个规则，可单独启用/禁用）-------------------------------
-- 原规则名: kitty-opacity
hl.window_rule({
  name = "Kitty·透明度",
  match = { class = "^(kitty)$" },
})

-- termfilechooser 悬浮文件选择器 ---------------------------------------------
-- 由 xdg-desktop-portal-termfilechooser 启动的 yazi 选择窗口（kitty，title=termfilechooser）
-- 强制浮动 + 0.9 透明度 + 屏幕 80% 居中
-- 原规则名: termfilechooser-float
hl.window_rule({
  name = "文件选择器·浮动居中",
  match = { title = ".*termfilechooser.*" },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.8",
  center = true,
  opacity = "0.9",
})

-- PeaZip 悬浮压缩管理 ---------------------------------------------------------
-- 启动时强制浮动 + 屏幕 80% 居中（纯配置方案）
-- 原规则名: peazip-float
hl.window_rule({
  name = "PeaZip·浮动居中",
  match = { class = ".*[Pp]ea[Zz]ip.*" },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.8",
  center = true,
})

-- mpv 悬浮播放器 ---------------------------------------------------------------
-- 强制浮动，占屏幕逻辑尺寸 80%，居中。纯配置方案（无 wrapper）
-- 原规则名: mpv-float
hl.window_rule({
  name = "mpv·浮动居中",
  match = { class = "^mpv$" },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.8",
  center = true,
})

-- eog 悬浮图像查看器 -----------------------------------------------------------
-- 强制浮动 + 屏幕 80% 居中（纯配置方案）
-- 原规则名: eog-float
hl.window_rule({
  name = "图像查看器·浮动居中",
  match = { class = "^(eog|org\\.gnome\\.eog)$" },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.8",
  center = true,
})

-- mkvextract 悬浮mkv提取器 -----------------------------------------------------------
-- 强制浮动 + 屏幕 80% 居中（纯配置方案）
-- 原规则名: mkvextract-float
hl.window_rule({
  name = "MKV提取器·浮动居中",
  match = { class = "mkvextract-gtk" },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.8",
  center = true,
})

-- 测试/示例窗口浮动 -------------------------------------------------------
-- 标题含有 "_demo_or_test" 的窗口自动浮动
-- 原规则名: dev-float
hl.window_rule({
  name = "开发·测试窗口浮动",
  match = { title = ".*_demo_or_test.*" },
  float = true,
})

-- Steam 浮动居中 ----------------------------------------------------------
-- 原规则名: steam-float
hl.window_rule({
  name = "Steam·浮动居中",
  match = { class = ".*steam.*" },
  float = true,
  center = true,
})

-- AnyTalk 语音输入浮层 ----------------------------------------------------
-- fcitx5-anytalk 的语音识别浮层：浮动、不抢占焦点、居中显示
-- 原规则名: anytalk-float
hl.window_rule({
  name = "AnyTalk·语音浮层",
  match = { class = "^(anytalk-overlay)$" },
  float = true,
  no_focus = true,
  center = true,
})

-- Wine 窗口浮动 -----------------------------------------------------------
-- 原规则名: wine-float
hl.window_rule({
  name = "Wine·浮动",
  match = { class = "^(wine|Wine|.*\\.[Ee][Xx][Ee])$" },
  float = true,
})

-- 工作区 9/10 半透明 -------------------------------------------------------
-- 9/10 号工作区所有窗口设 0.8 透明度
-- 原规则名: ws9-transparent
hl.window_rule({
  name = "工作区9·半透明",
  match = { workspace = "9" },
  opacity = "0.89",
})
-- 原规则名: ws10-transparent
hl.window_rule({
  name = "工作区10·半透明",
  match = { workspace = "10" },
  opacity = "0.89",
})

-- QQ 悬浮窗口 ---------------------------------------------------------------
-- 新建窗口浮动；纵向 3:4，高度为屏幕高度的 0.8（宽 = 0.8 * 3/4 = 0.6 倍屏高）
-- 原规则名: qq-float
hl.window_rule({
  name = "QQ·悬浮居中窗口",
  match = { class = "^QQ$" },
  float = true,
  size = "monitor_h*0.6 monitor_h*0.8",
  center = true,
})

hl.window_rule({
  name = "hypr-tuner:QQ·悬浮居中窗口",
  match = {
    class = "^QQ$",
  },
  float = true,
  center = true,
  size = "monitor_w*0.5 monitor_h*0.8",
})

hl.window_rule({
  name = "hypr-tuner:FlClash",
  match = {
    title = "flclash",
  },
  workspace = "10",
})

hl.window_rule({
  name = "hypr-tuner:flclash",
  match = {
    class = "^com.follow.clash$",
  },
  workspace = "10",
})

hl.window_rule({
  name = "hypr-tuner:zen-browser",
  match = {
    class = "^zen\\-browser$",
  },
  border_size = 2,
})

-- ============================================================================
-- hl.window_rule() 全部可用字段参考
-- ============================================================================
-- hl.window_rule({
--   name  = "规则名",           -- 可选，用于动态启用/禁用
--
--   -- 匹配条件（至少一个）:
--   match = {
--     class    = "字符串",      -- 窗口类名（APP_ID），支持 Lua 正则
--     title    = "字符串",      -- 窗口标题，支持正则
--     xwayland = true,          -- XWayland 窗口
--     float    = true,          -- 浮动窗口
--     fullscreen = true,        -- 全屏窗口
--     pinned   = true,          -- 固定窗口
--     workspace = "1",          -- 在工作区上的窗口
--     all      = true,          -- 匹配所有窗口（兜底用）
--   },
--
--   -- 静态效果（设置一次即固定，窗口不持续追踪）:
--   float    = true,            -- 设为浮动
--   tile     = true,            -- 设为平铺
--   fullscreen = 0,             -- 0=关  1=全屏  2=全屏不含保留区  3=全屏最大化
--   move     = "x y",           -- 移动到坐标，如 "660 960"
--   size     = "宽 高",         -- 设置大小，如 "1650 880"
--   center   = true,            -- 居中
--   workspace = "1",            -- 发送到指定工作区
--   workspace = "special:xxx",  -- 发送到草稿箱
--   monitor  = "eDP-1",         -- 发送到指定显示器
--   pin      = true,            -- 固定（在所有工作区可见）
--   swallow  = true,            -- 吞入（子窗口覆盖父窗口）
--
--   -- 动态效果（窗口持续追踪，属性改变时会跟随）:
--   opacity   = "0.85",         -- 透明度，数值 0~1
--   no_focus  = true,           -- 不抢占焦点
--   no_blur   = true,           -- 不模糊背景
--   no_shadow = true,           -- 不显示阴影
--   border_color = "rgba(...)", -- 边框颜色
--   rounding  = true,           -- 启用圆角
--   gaps      = 数字,           -- 窗口间隙覆盖
--   dimaround = true,           -- 窗口周围变暗
--   group     = "name",         -- 窗口组
--   idle      = true,           -- 不影响系统的空闲检测
--
--   -- 特殊:
--   suppress_event = "maximize",  -- 阻止窗口最大化请求
--     -- 可取值: "maximize" "fullscreen" "activate" "activatefocus"
-- })
-- ============================================================================
-- 动态规则（运行时启用/禁用）:
--   hyprctl setrule "规则名" enable
--   hyprctl setrule "规则名" disable
-- 例:
--   hyprctl setrule "Kitty·浮动" disable  -- 临时取消 Kitty 浮动
-- ============================================================================


-- ============================================================================
-- 锁屏遮罩（lock-veil）：浮动 + 置顶 + 比屏幕更大 + 无任何装饰
-- 目的：锁屏时盖一层半透明黑做强烈视觉切换，且不参与平铺、不挤压其它窗口，
--       尺寸超出屏幕让边框/圆角落在屏幕外，肉眼看不到边缘。
-- ============================================================================
hl.window_rule({
  name = "lock-veil·浮动超大无装饰",
  match = { class = "^lock-veil$" },
  float = true,
  size = "2200 1300",
  move = "-140 -110",
  decorate = false,
  no_shadow = true,
  no_blur = true,
  no_anim = true,
  stay_focused = false,
})

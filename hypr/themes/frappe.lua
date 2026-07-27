-- ============================================================================
-- Catppuccin Frappe 配色主题（Lua 格式）
-- ============================================================================
-- 颜色格式：0xAARRGGBB（AA = alpha, 0xff = 完全不透明）
-- 使用方法：
--   local theme = require("themes.frappe")
--   hl.config({
--     general = {
--       col.active_border = theme.mauve,
--     },
--   })
-- 其他风味：latte（亮色）/ macchiato（柔和）/ mocha（深色）
-- 旧版 hyprlang 文件在 themes/*.conf 中
-- ============================================================================

return {
  rosewater = 0xfff2d5cf,   -- 玫瑰水（粉白）
  flamingo  = 0xffeebebe,   -- 火烈鸟（淡粉）
  pink      = 0xfff4b8e4,   -- 粉色
  mauve     = 0xffca9ee6,   -- 紫罗兰（主色）
  red       = 0xffe78284,   -- 红色（错误/警告）
  maroon    = 0xffea999c,   -- 栗色（强调）
  peach     = 0xffef9f76,   -- 桃色（橙色系）
  yellow    = 0xffe5c890,   -- 黄色（警告）
  green     = 0xffa6d189,   -- 绿色（成功）
  teal      = 0xff81c8be,   -- 青色
  sky       = 0xff99d1db,   -- 天蓝色
  sapphire  = 0xff85c1dc,   -- 宝石蓝
  blue      = 0xff8caaee,   -- 蓝色（链接）
  lavender  = 0xffbabbf1,   -- 薰衣草（次色）
  text      = 0xffc6d0f5,   -- 正文文本
  subtext1  = 0xffb5bfe2,   -- 次要文本（深）
  subtext0  = 0xffa5adce,   -- 次要文本（浅）
  overlay2  = 0xff949cbb,   -- 覆盖层（高对比）
  overlay1  = 0xff838ba7,   -- 覆盖层（中）
  overlay0  = 0xff737994,   -- 覆盖层（低）
  surface2  = 0xff626880,   -- 表面色（最深）
  surface1  = 0xff51576d,   -- 表面色（中）
  surface0  = 0xff414559,   -- 表面色（最浅）
  base      = 0xff303446,   -- 底色（背景）
  mantle    = 0xff292c3c,   -- 地幔色（侧栏/面板背景）
  crust     = 0xff232634,   -- 地壳色（最深背景）
}

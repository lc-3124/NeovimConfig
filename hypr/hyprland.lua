-- ============================================================================
-- Hyprland 主配置入口 (Lua)
--
-- 本文件只做模块装配：所有实际配置都在 configure/ 目录下。
-- 新增功能请加模块文件并在此处 require，不要往本文件里写逻辑。
-- ============================================================================

require("configure.env")
require("configure.looking&basics")
require("configure.monitor")
require("configure.permissions")
require("configure.keybind")
require("configure.typical")

require("configure.hyprvim")   -- WhichKey 快捷键提示浮层
require("configure.escape")    -- 全局 ESC 策略（取消截图 / 关浮层 / 转发）
require("configure.screen")    -- screen / screen-move 子图（跨屏焦点与移窗）
require("configure.cursor")    -- cursor 子图（网格选点后的方向/点击）

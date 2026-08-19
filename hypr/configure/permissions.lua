-- ============================================================================
-- 生态权限模块（permissions）
-- ============================================================================
-- 为常用工具配置 Hyprland 生态权限的永久放行（enforce_permissions=true 时生效）。
-- 权限类型：
--   screencopy   —— 截屏/录屏（grim、hyprshot、portal）
--   cursorpos    —— 读取/控制光标位置（截图工具、远程控制）
--   keyboard     —— 键盘事件注入（远程输入、自动化）
--   plugin       —— 插件加载（hyprpm 等）
--   input-capture —— 输入捕获（共享输入设备）
-- 放行模式：allow / deny / ask
--
-- 注意：权限规则仅在 Hyprland「首次启动」时应用，
--       修改本文件后需要重启 Hyprland 才生效（hyprctl reload 不生效）。
-- ============================================================================

-- 截图工具链：grim / slurp / 自定义 screenshot 脚本
hl.permission({ binary = "/usr/bin/grim",            type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/slurp",           type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/grim",            type = "cursorpos",  mode = "allow" })
hl.permission({ binary = "/usr/bin/slurp",           type = "cursorpos",  mode = "allow" })
hl.permission({ binary = "/home/lc3124/.local/bin/screenshot", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/home/lc3124/.local/bin/screenshot", type = "cursorpos",  mode = "allow" })

-- xdg-desktop-portal-hyprland：应用通过 portal 请求截屏/录屏
hl.permission({ binary = "/usr/lib/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })

-- hyprlock：锁屏（若需要截取壁纸背景等）
hl.permission({ binary = "/usr/bin/hyprlock", type = "screencopy", mode = "allow" })

-- hypr-kdeconnect-portal：KDE Connect 远程输入（指针/键盘注入）
hl.permission({ binary = "/usr/bin/hypr-kdeconnect-portal", type = "cursorpos", mode = "allow" })
hl.permission({ binary = "/usr/bin/hypr-kdeconnect-portal", type = "keyboard",  mode = "allow" })
hl.permission({ binary = "/usr/bin/hypr-kdeconnect-portal", type = "input-capture", mode = "allow" })

-- 键盘注入 / 光标控制相关自动化工具（按需）
-- hl.permission({ binary = "/usr/bin/ydotool",       type = "keyboard",  mode = "allow" })
-- hl.permission({ binary = "/usr/bin/ydotool",       type = "cursorpos", mode = "allow" })
-- hl.permission({ binary = "/usr/bin/wtype",         type = "keyboard",  mode = "allow" })

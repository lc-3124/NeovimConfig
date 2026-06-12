-- Hyprland 主配置 — TokyoNight Storm
-- 拆分模块: config / keybinds / windowrules/*

require("config")
require("keybinds")
require("windowrules.global")
require("windowrules.kitty")
require("windowrules.steam")
require("windowrules.xwayland")

hl.exec_cmd("fcitx5 -d")
hl.exec_cmd("waybar")
hl.exec_cmd("hyprpaper")

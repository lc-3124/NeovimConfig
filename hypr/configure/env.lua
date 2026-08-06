-- ============================================================================
-- 环境变量 & 自启动模块
-- ============================================================================

-- 环境变量 ------------------------------------------------
-- hl.env("KEY", "VALUE") 设置环境变量
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- 权限系统：Hyprland 从 0.45+ 引入的生态权限
hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

-- 自启动 ------------------------------------------------
-- hl.on("hyprland.start") 替代旧版 exec-once
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("wayle panel start")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 3 && ~/.config/hypr/scripts/usb-reset-hub.sh")
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/resource/images/Bamboo_clear.png -o eDP-1 --transition-type grow --transition-pos bottom-right --transition-duration 0.8 --transition-fps 24")
end)

-- ============================================================================
-- 环境变量 & 自启动模块
-- ============================================================================

-- 环境变量 ------------------------------------------------
-- hl.env("KEY", "VALUE") 设置环境变量
-- 注：kdeconnect/qbittorrent 等主流应用是 Qt6，须用 qt6ct；
--     Qt5 应用（如需要）可由其自身启动脚本指定 QT_QPA_PLATFORMTHEME=qt5ct 覆盖
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Electron/Chromium 应用（QQ、VS Code 等）自动优先走原生 Wayland，
-- 规避 XWayland 下 XIM 输入法丢键等问题；支持 Wayland 的才启用，否则回退 X11
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
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
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/resource/images/Bamboo_clear.png -o eDP-1 --transition-type grow --transition-pos bottom-right --transition-duration 0.8 --transition-fps 24")
end)

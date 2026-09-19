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
-- GTK 应用的文件/颜色/字体等对话框强制走 xdg-desktop-portal，
-- 由 portals.conf 路由到 termfilechooser（yazi+kitty 终端文件选择器）
hl.env("GTK_USE_PORTAL", "1")
-- 注意：不要在这里全局强制 XWayland 走 NVIDIA。
-- 本机显示由 Intel 核显负责，独显(T600)会被 dgpu-switch 脚本从 PCI 总线移除；
-- 一旦独显不可用，__GLX_VENDOR_LIBRARY_NAME=nvidia 会让所有 XWayland/GL 应用
-- （包括 Minecraft 的 GLFW）创建 GLX 上下文失败，报 GLXBadFBConfig 而无法启动。
-- 需要单款游戏用独显时，请在插电、独显已恢复后按应用单独指定（prime-run 或
-- 启动命令前加环境变量），不要全局生效。
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- 光标闪烁修复（nvidia-drm.modeset=1 下视驱动版本而定，保留无害）
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

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
  -- 剪贴板历史：wl-paste 监听剪贴板变化，交给 cliphist 存档（文本与图片通吃）
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("fcitx5 -d")
  -- 权限认证服务：先清除失败计数（避免 start-limit 锁死），再重启
  hl.exec_cmd("systemctl --user reset-failed hyprpolkitagent; systemctl --user restart hyprpolkitagent")
  hl.exec_cmd("wayle panel start")
  -- 壁纸：固定使用 resource/images/background.png
  -- 之后的壁纸切换全部交给we-gui
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/resource/images/background.png -o eDP-1")
end)

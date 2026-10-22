-- ============================================================================
-- 环境变量 & 自启动模块
--
-- 注意：本分支（xiaoxin）刻意不含任何硬件强绑定配置：
--   * 无 NVIDIA 独显相关（AQ_DRM_DEVICES / EGL vendor / prime-run）
--   * 无外接屏专用实例（wayle-hdmi）
--   * 显示器布局保持「首选分辨率 + 自动位置」（见 monitor.lua）
-- 主机特定的机器上再按需覆盖，不要把 T600 / ThinkPad 的东西带过来。
-- ============================================================================

-- 环境变量 ------------------------------------------------
-- hl.env("KEY", "VALUE") 设置环境变量
-- 注：kdeconnect/qbittorrent 等主流应用是 Qt6，须用 qt6ct；
--     Qt5 应用（如需要）可由其自身启动脚本指定 QT_QPA_PLATFORMTHEME=qt5ct 覆盖
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Qt 全局缩放：内置屏通常 1.2 缩放，这里整体乘 0.8（≈0.96），
-- 让所有 Qt6 应用（kdenlive、wayle/quickshell 面板等）一起小一档。
-- 注意：只影响 Qt 应用；GTK/Electron 不受影响。改动需重新登录 Hyprland 才生效。
hl.env("QT_SCALE_FACTOR", "0.8")
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

-- 会话 locale 与输入法 --------------------------------------------------------
-- 图形会话不读 ~/.zshrc；这里兜底设一遍，确保 Hyprland 及其启动的所有 GUI 应用都拿到。
hl.env("LANG", "zh_CN.UTF-8")
hl.env("LANGUAGE", "zh_CN:zh")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

-- 权限系统：Hyprland 0.45+ 引入的生态权限
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
  -- Quickshell：承载 HyprVim 的 WhichKey HUD（独立浮层，不占状态栏）
  hl.exec_cmd("quickshell")
  -- 壁纸：固定使用 resource/images/background.png（不指定 output，铺满所有显示器）
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/resource/images/background.png")
  -- 空闲守护：10 分钟无操作锁屏（配置见 hypridle.conf；与 META+L 同一脚本 lock.sh）
  -- 已按用户要求关闭 10 分钟自动锁屏（恢复时删掉下一行注释）
  -- hl.exec_cmd("pgrep -x hypridle >/dev/null || hypridle")
  -- dotool 常驻服务端（hyprwarp 的点击/移动回调经 dotoolc 发给它）
  hl.exec_cmd("pgrep -x dotoold >/dev/null || dotoold")

  -- 蓝牙配对 agent：负责弹出配对码输入/确认框（blueman-applet 提供 Agent1）
  hl.exec_cmd("pgrep -f blueman-applet >/dev/null || blueman-applet")
end)

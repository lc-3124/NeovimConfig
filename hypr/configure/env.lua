-- ============================================================================
-- 环境变量 & 自启动模块
-- ============================================================================

-- 环境变量 ------------------------------------------------
-- hl.env("KEY", "VALUE") 设置环境变量
-- 注：kdeconnect/qbittorrent 等主流应用是 Qt6，须用 qt6ct；
--     Qt5 应用（如需要）可由其自身启动脚本指定 QT_QPA_PLATFORMTHEME=qt5ct 覆盖
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Qt 全局缩放：显示器 eDP-1 scale=1.2，这里整体乘 0.8（≈0.96），
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
-- 只让 Hyprland/Aquamarine 使用 Intel 核显（/dev/dri/igpu 由 udev 规则
-- /etc/udev/rules.d/99-dri-igpu.rules 稳定指向核显）。
-- 这样 Hyprland 不再占用独显，dgpu-power.sh 的 off/reload 才能成功；
-- 外接显示器都接在核显上，不受影响。改动需重启 Hyprland（重新登录）才生效。
hl.env("AQ_DRM_DEVICES", "/dev/dri/igpu")
-- glvnd 的 EGL 设备枚举会加载 libEGL_nvidia 并打开 /dev/nvidia*，导致 Hyprland
-- 以及浏览器/Electron(如 QQ) 一直占用独显，dgpu-power.sh 的 off 就永远被拒。
-- 这里只保留 Mesa 的 EGL vendor，让 EGL 枚举看不到独显（显示/渲染本来就走核显）。
-- 实测不影响 GLX 的 prime-run 独显卸载（prime-run glxinfo 仍显示 NVIDIA T600），
-- 也不影响 Vulkan（走 ICD）。若个别应用确实需要 EGL 用独显，可临时：
--   env -u __EGL_VENDOR_LIBRARY_FILENAMES prime-run 应用
hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json")
-- 注意：不要在这里全局强制 XWayland 走 NVIDIA。
-- 本机显示由 Intel 核显负责，独显(T600)会被 dgpu-switch 脚本从 PCI 总线移除；
-- 一旦独显不可用，__GLX_VENDOR_LIBRARY_NAME=nvidia 会让所有 XWayland/GL 应用
-- （包括 Minecraft 的 GLFW）创建 GLX 上下文失败，报 GLXBadFBConfig 而无法启动。
-- 需要单款游戏用独显时，请在插电、独显已恢复后按应用单独指定（prime-run 或
-- 启动命令前加环境变量），不要全局生效。
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- 光标闪烁修复（nvidia-drm.modeset=1 下视驱动版本而定，保留无害）
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- 会话 locale 与输入法 --------------------------------------------------------
-- SDDM 启动的图形会话不读 ~/.zshrc；系统层已设（/etc/locale.conf + /etc/environment），
-- 这里再兜底设一遍，确保 Hyprland 及其启动的所有 GUI 应用（含 Minecraft）都拿到。
hl.env("LANG", "zh_CN.UTF-8")
hl.env("LANGUAGE", "zh_CN:zh")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

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
  -- 外接屏 HDMI-A-1：独立 wayle 实例（顶部横栏、仅工作区切换 11–20）
  hl.exec_cmd("~/.config/hypr/scripts/wayle-hdmi.sh")
  -- Quickshell：承载 HyprVim 的 WhichKey HUD（独立浮层，不占状态栏）
  hl.exec_cmd("quickshell")
  -- 壁纸：固定使用 resource/images/background.png
  -- 之后的壁纸切换全部交给we-gui
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/resource/images/background.png -o eDP-1")
  -- 空闲守护：10 分钟无操作锁屏（配置见 hypridle.conf；与 META+L 同一脚本 lock.sh）
  -- 已按用户要求关闭 10 分钟自动锁屏（恢复时删掉下一行注释）
  -- hl.exec_cmd("pgrep -x hypridle >/dev/null || hypridle")
  -- dotool 常驻服务端（hyprwarp 的点击/移动回调经 dotoolc 发给它）
  hl.exec_cmd("pgrep -x dotoold >/dev/null || dotoold")

  -- 蓝牙配对 agent：负责弹出配对码输入/确认框（blueman-applet 提供 Agent1）
  hl.exec_cmd("pgrep -f blueman-applet >/dev/null || blueman-applet")
  -- 平滑光标/滚动守护（hyprwarp 光标模式用）
  -- 光标移动改由常驻守护 hypr-cursor（systemd，直接读 evdev）负责
  -- hl.exec_cmd("~/.config/hypr/scripts/cursor-mover.sh")
end)

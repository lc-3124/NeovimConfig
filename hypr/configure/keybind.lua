--===========================================================================
-- 快捷键绑定模块
-- ============================================================================
-- hl.bind(keys, dispatcher, opts?)
--   keys      : 修饰键组合，如 "SUPER + Q"（+ 两侧空格可选）
--   dispatcher: hl.dsp.* 返回的 dispatcher 闭包
--   opts      : { locked, release, repeating, click, description, ... }
-- hl.define_submap(name, reset?, fn) — 定义子映射
-- ============================================================================
-- 注：本配置会被脚本解析生成 fuzzel 快捷键列表，添加绑定时需按约定格式
-- AGENTS: 在增添任意代码配置时，请参考本文件全局的配置格式。
-- ============================================================================

local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"

-- 打开终端
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal), { description = "打开终端" })
-- 剪贴板历史
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"), { description = "剪贴板历史" })
-- 关闭窗口
hl.bind(mainMod .. " + C", hl.dsp.window.close(), { description = "关闭窗口" })
-- 强制结束进程
hl.bind(mainMod .. " + F4", hl.dsp.window.kill(), { description = "强制结束进程" })
-- 退出 Hyprland
hl.bind(mainMod .. " + M", hl.dsp.exit(), { description = "退出 Hyprland" })
-- 锁定屏幕
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"), { description = "锁定屏幕" })
-- 锁屏并挂起
hl.bind("META + ALT + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock-suspend.sh"), { locked = true, description = "锁屏并挂起" })
-- 熄屏/恢复
hl.bind("META + ALT + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-screen.sh"), { locked = true, description = "熄屏/恢复" })
-- 文件管理器
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "文件管理器" })
-- 切换窗口浮动
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "切换窗口浮动" })
-- 启动器
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("fuzzel"), { description = "启动器" })
-- 伪平铺
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "伪平铺" })

-- 焦点向左移
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  { description = "焦点向左" })
-- 焦点向右移
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "焦点向右" })
-- 焦点向上移
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    { description = "焦点向上" })
-- 焦点向下移
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  { description = "焦点向下" })

-- 窗口向左移
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }),  { description = "窗口向左移" })
-- 窗口向右移
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "窗口向右移" })
-- 窗口向上移
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }),    { description = "窗口向上移" })
-- 窗口向下移
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }),  { description = "窗口向下移" })

-- 窗口向上缩
hl.bind(mainMod .. " + CTRL + SHIFT + up",   hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { description = "窗口高度 −50" })
-- 窗口向下扩
hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }),  { description = "窗口高度 +50" })

-- ============================================================================
-- 工作区操作：按「当前聚焦显示器」映射，两块屏完全隔离
--   单屏（内置 eDP-1）→ 工作区 1–10
--   多屏时在 WS_BASE 里补映射即可（如 ["HDMI-A-1"] = 11）
--   SUPER+1..0 只操作「当前屏」那一套，绝不会跳到另一块屏。
-- ============================================================================
local WS_BASE = { ["eDP-1"] = 1 }

local function ws_base()
  local m = hl.get_active_monitor()
  return (m and WS_BASE[m.name]) or 1
end

-- 聚焦当前屏的第 n 个工作区（n = 1..10）
for i = 1, 10 do
  local key = (i == 10) and "0" or tostring(i)
  local offset = i - 1
  hl.bind(mainMod .. " + " .. key, function()
    hl.dispatch(hl.dsp.focus({ workspace = ws_base() + offset }))
  end, { description = "当前屏第 " .. i .. " 工作区" })
  hl.bind(mainMod .. " + SHIFT + " .. key, function()
    hl.dispatch(hl.dsp.window.move({ workspace = ws_base() + offset }))
  end, { description = "窗口 → 当前屏第 " .. i .. " 工作区" })
end

-- 在当前屏的 10 个工作区内循环切换（step = ±1）
local function ws_focus_step(step)
  return function()
    local base = ws_base()
    local cur = hl.get_active_workspace()
    local idx = (((cur and cur.id or base) - base) % 10 + 10) % 10
    hl.dispatch(hl.dsp.focus({ workspace = base + (idx + step) % 10 }))
  end
end
local function ws_move_step(step)
  return function()
    local base = ws_base()
    local cur = hl.get_active_workspace()
    local idx = (((cur and cur.id or base) - base) % 10 + 10) % 10
    hl.dispatch(hl.dsp.window.move({ workspace = base + (idx + step) % 10 }))
  end
end

-- 切换草稿箱
hl.bind(mainMod .. " + S",                    hl.dsp.workspace.toggle_special("magic"), { description = "切换草稿箱 magic" })
-- 窗口移入草稿箱
hl.bind(mainMod .. " + SHIFT + S",            hl.dsp.window.move({ workspace = "special:magic" }), { description = "窗口 → 草稿箱" })

-- 在当前屏内滚动切换工作区（不越到另一块屏）
hl.bind(mainMod .. " + mouse_down",           ws_focus_step(1))
hl.bind(mainMod .. " + mouse_up",             ws_focus_step(-1))

-- 快速切换当前屏相邻工作区
hl.bind(mainMod .. " + CTRL + left",          ws_focus_step(-1), { description = "当前屏上一工作区" })
hl.bind(mainMod .. " + CTRL + right",         ws_focus_step(1),  { description = "当前屏下一工作区" })
hl.bind(mainMod .. " + CTRL + up",            ws_focus_step(-1), { description = "当前屏上一工作区" })
hl.bind(mainMod .. " + CTRL + down",          ws_focus_step(1),  { description = "当前屏下一工作区" })
-- 调整窗口宽度（META+CTRL+SHIFT+←/→）
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "窗口宽度 −50" })
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }),  { description = "窗口宽度 +50" })

-- ============================================================================
-- 屏幕间导航（子图实现，Hyprland 不支持三键和弦）
--   SUPER + W          → 进入选屏模式，再按 ← / →，焦点切到 左/右 显示器
--   SUPER + SHIFT + W  → 进入携窗模式，再按 ← / →，把窗口带到 左/右 显示器
--   ESC 退出子图；任何一次 ← / → 执行后也自动退出
-- ============================================================================
-- （screen / screen-move 子图的定义已移到 hyprland.lua，放在全局 ESC unbind 之后，
--   以免子图内的 ESC 退出绑定被一并移除）

hl.bind(mainMod .. " + W",         hl.dsp.submap("screen"),      { description = "+屏幕焦点" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.submap("screen-move"), { description = "+屏幕移动" })

-- 关闭所有通知
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("/home/lc3124/.local/bin/wayle-dismiss-all"), { description = "关闭所有通知" })

-- 移动浮动窗口（META+ALT+方向，按住连续）
hl.bind("META + ALT + left",  hl.dsp.window.move({ x = -50, y = 0, relative = true }), { repeating = true, description = "浮动窗口 ←" })
hl.bind("META + ALT + right", hl.dsp.window.move({ x = 50, y = 0, relative = true }),  { repeating = true, description = "浮动窗口 →" })
hl.bind("META + ALT + up",    hl.dsp.window.move({ x = 0, y = -50, relative = true }), { repeating = true, description = "浮动窗口 ↑" })
hl.bind("META + ALT + down",  hl.dsp.window.move({ x = 0, y = 50, relative = true }),  { repeating = true, description = "浮动窗口 ↓" })

-- 切换分割方向
hl.bind(mainMod .. " + G", hl.dsp.layout("togglesplit"), { description = "切换分割方向" })

-- 开关鼠标（指针类设备：鼠标/触摸板/指点杆）
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-mouse.sh"), { description = "开关鼠标" })

-- 键盘选点点击（hyprwarp + dotool）；选点后进入 cursor 子图做点击/拖拽/滚动
hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-enter.sh"), { description = "光标模式（居中）" })

-- 光标模式操作手册
hl.bind("META + SHIFT + semicolon", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprwarp-once.sh"), { description = "键盘选点点击 (hyprwarp)" })

-- 紧急恢复：杀掉卡住的 hyprwarp / 退出子图（防输入被抢）
hl.bind("META + SHIFT + escape", hl.dsp.exec_cmd("pkill -x hyprwarp 2>/dev/null; rm -f ${XDG_RUNTIME_DIR:-/tmp}/hypr-cursor-active; hyprctl dispatch 'hl.dsp.submap(\"reset\")'"), { locked = true, description = "紧急恢复(杀 hyprwarp)" })

-- 光标模式操作手册
hl.bind("META + ALT + semicolon", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-help.sh"), { description = "光标模式手册" })
hl.bind("META + ALT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/tray-pick.py"), { description = "托盘（键盘选择）" })


-- 拖拽窗口
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { description = "拖拽窗口" })
-- 调整窗口大小
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "调整窗口大小" })

-- 音量增大
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),      { locked = true, release = true, description = "音量 +" })
-- 音量减小
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),            { locked = true, release = true, description = "音量 −" })
-- 静音切换
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true, release = true, description = "输出静音" })
-- 麦克风静音
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),        { locked = true, release = true, description = "麦克风静音" })
-- 亮度增加
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                       { locked = true, release = true, description = "亮度 +" })
-- 亮度减小
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                      { locked = true, release = true, description = "亮度 −" })

-- 下一曲
hl.bind("XF86AudioNext",   hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "下一曲" })
-- 暂停/播放
hl.bind("XF86AudioPause",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "暂停/播放" })
-- 暂停/播放
hl.bind("XF86AudioPlay",   hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "播放" })
-- 上一曲
hl.bind("XF86AudioPrev",   hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "上一曲" })

-- 截取区域
hl.bind("Print",          hl.dsp.exec_cmd("$HOME/.local/bin/screenshot region"), { description = "区域截图" })
-- 截取全屏
hl.bind("SHIFT + Print",  hl.dsp.exec_cmd("$HOME/.local/bin/screenshot full"),   { description = "全屏截图" })
-- 截取当前窗口
hl.bind("CTRL + Print",   hl.dsp.exec_cmd("$HOME/.local/bin/screenshot focused"),{ description = "窗口截图" })

-- 语音输入
hl.bind("F2",                         hl.dsp.exec_cmd("busctl --user call org.fcitx.Fcitx5.AnyTalk.Overlay /overlay org.fcitx.Fcitx5.AnyTalk.Overlay ToggleRecording"), { description = "语音输入" })

-- 放大镜放大
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]), { description = "放大镜 放大" })

-- 放大镜缩小
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 0.9 | if . < 1 then 1 else . end'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]) , { description = "放大镜 缩小" })

-- 屏幕缩放增大
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/scale.sh +"), { description = "屏幕缩放 +" })
-- 屏幕缩放减小
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/scale.sh -"), { description = "屏幕缩放 −" })

-- ============================================================================
-- hl.bind() 全部可用参数参考
-- ============================================================================
-- hl.bind(keys, dispatcher, opts?)
--
-- keys ─ 按键组合，用 ` + ` 连接
--   修饰键: SUPER(Windows)  CTRL  SHIFT  ALT
--   方向键: left  right  up  down
--   鼠标:   mouse_down  mouse_up  mouse:272(左键)  mouse:273(右键)
--   多媒体: XF86AudioNext  XF86AudioPlay  XF86MonBrightnessUp ...
--   打印:   Print
--   功能键: F1 F2 ... F12
--   组合示例: "SUPER + SHIFT + Q"  "META + ALT + left"
--
-- dispatcher ─ hl.dsp.* 动作闭包
--   程序执行:     hl.dsp.exec_cmd("命令")
--   窗口操作:
--     hl.dsp.window.close()            关闭
--     hl.dsp.window.kill()             强制结束
--     hl.dsp.window.float({action=     切换浮动 ("toggle" / "on" / "off")
--       "toggle"})
--     hl.dsp.window.pseudo()           伪平铺
--     hl.dsp.window.drag()             拖拽
--     hl.dsp.window.resize({x=,y=,     调整大小（relative=true 为相对值）
--       relative=true})
--     hl.dsp.window.move({direction=   窗口向方向移动
--       "left"})
--     hl.dsp.window.move({workspace=   窗口移到工作区
--       "1"})
--     hl.dsp.window.move({x=, y=})     窗口移到绝对坐标
--     hl.dsp.window.swap({direction=   与相邻窗口交换
--       "left"})
--     hl.dsp.window.move({into_group=  移入/移出窗口组
--       true})
--     hl.dsp.window.move({out_of_group=
--       true})
--   焦点操作:
--     hl.dsp.focus({direction="left"}) 焦点移向方向
--     hl.dsp.focus({workspace="1"})    切换到工作区
--     hl.dsp.focus({x=, y=})           焦点移到坐标位置
--     hl.dsp.focus({monitor="eDP-1"})  焦点移到特定显示器
--   工作区:
--     hl.dsp.workspace.toggle_special( 切换草稿箱
--       "name")
--   布局:
--     hl.dsp.layout("togglesplit")     切换分割方向
--     hl.dsp.layout("swap")            交换主从窗口
--     hl.dsp.layout("centerwindow")    居中窗口
--     hl.dsp.layout("splitsmart")      智能切换分割
--   系统:
--     hl.dsp.exit()                    退出 Hyprland
--     hl.dsp.exec_cmd("命令")          Shell 命令
--
-- opts ─ 可选参数表（选填）
--   { locked = true,         -- 锁屏下也可用（多媒体键常用）
--     release = true,       -- 松手触发（而非按下）
--     repeating = true,     -- 按住连续触发
--     description = "说明", -- 描述文本（WhichKey / 速查表用）
--     submap = "名称" }     -- 子映射名
-- ============================================================================
-- hl.define_submap(name, reset?, fn) ─ 定义子映射
--   子映射: 一组临时快捷键，进入子映射后原快捷键失效，退出后恢复
--   hl.define_submap("resize", false, function()
--     hl.bind("left",  hl.dsp.window.resize({x=-50,y=0,relative=true}))
--     hl.bind("right", hl.dsp.window.resize({x=50,y=0,relative=true}))
--     hl.bind("escape", hl.dsp.exec_cmd("hl.dispatch.submap.reset"))
--   end)
--   进入: hl.bind("SUPER + R", hl.dsp.exec_cmd("hl.dispatch.submap.resize"))
-- ============================================================================


-- ============================================================================
-- ============================================================================

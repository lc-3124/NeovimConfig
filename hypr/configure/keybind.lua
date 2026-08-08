-- ============================================================================
-- 快捷键绑定模块
-- ============================================================================
-- hl.bind(keys, dispatcher, opts?)
--   keys      : 修饰键组合，如 "SUPER + Q"（+ 两侧空格可选）
--   dispatcher: hl.dsp.* 返回的 dispatcher 闭包
--   opts      : { locked, release, repeating, click, ... }
-- hl.define_submap(name, reset?, fn) — 定义子映射
-- ============================================================================
-- 注：本配置项目会用脚本解析这个文件夹来获取快捷键列表进而交给fuzzel显示，
-- 添加绑定时要按照约定的格式。
-- ============================================================================

local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"

-- 打开终端
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
-- 关闭窗口
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- 强制结束进程
hl.bind(mainMod .. " + F4", hl.dsp.window.kill())
-- 退出 Hyprland
hl.bind(mainMod .. " + M", hl.dsp.exit())
-- 锁定屏幕（Meta + L，背景跟随当前壁纸）
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"), { description = "lock screen" })
-- 文件管理器
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
-- 切换窗口浮动
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- 启动器
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("fuzzel"))
-- 伪平铺
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- 显示快捷键列表
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"))

-- 焦点向左移
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
-- 焦点向右移
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
-- 焦点向上移
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
-- 焦点向下移
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- 窗口向左移
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
-- 窗口向右移
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
-- 窗口向上移
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
-- 窗口向下移
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- 窗口向上缩
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
-- 窗口向下扩
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- 切换到工作区 1~9
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
-- 切换到工作区 10
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- 窗口移到工作区 1~9
for i = 1, 9 do
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
-- 窗口移到工作区 10
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- 切换草稿箱
hl.bind(mainMod .. " + S",                    hl.dsp.workspace.toggle_special("magic"))
-- 窗口移入草稿箱
hl.bind(mainMod .. " + SHIFT + S",            hl.dsp.window.move({ workspace = "special:magic" }))

-- 上一个工作区
hl.bind(mainMod .. " + mouse_down",           hl.dsp.focus({ workspace = "+1" }))
-- 下一个工作区
hl.bind(mainMod .. " + mouse_up",             hl.dsp.focus({ workspace = "-1" }))

-- 快速切换相邻工作区
hl.bind(mainMod .. " + CTRL + left",          hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + right",         hl.dsp.focus({ workspace = "+1" }))
-- 携带窗口移动到侧边工作区
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }))

-- 关闭所有通知
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("wayle notify dismiss-all"))

-- 切换分割方向
hl.bind(mainMod .. " + W", hl.dsp.layout("togglesplit"))

-- 拖拽窗口
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),  { description = "move window" })
-- 调整窗口大小
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "resize window" })

-- 音量增大
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),      { locked = true, release = true })
-- 音量减小
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),            { locked = true, release = true })
-- 静音切换
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true, release = true })
-- 麦克风静音
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),        { locked = true, release = true })
-- 亮度增加
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                       { locked = true, release = true })
-- 亮度减小
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                      { locked = true, release = true })

-- 下一曲
hl.bind("XF86AudioNext",   hl.dsp.exec_cmd("playerctl next"),       { locked = true })
-- 暂停/播放
hl.bind("XF86AudioPause",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- 暂停/播放
hl.bind("XF86AudioPlay",   hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- 上一曲
hl.bind("XF86AudioPrev",   hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- 截取区域
hl.bind("Print",          hl.dsp.exec_cmd("screenshot region"))
-- 截取全屏
hl.bind("SHIFT + Print",  hl.dsp.exec_cmd("screenshot full"))
-- 截取当前窗口
hl.bind("CTRL + Print",   hl.dsp.exec_cmd("screenshot focused"))

-- 下一张壁纸
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/cycle-wallpaper.sh next"))
-- 切换壁纸效果
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.config/hypr/scripts/cycle-wallpaper.sh toggle"))

-- 语音输入
hl.bind("F2",                         hl.dsp.exec_cmd("busctl --user call org.fcitx.Fcitx5.AnyTalk.Overlay /overlay org.fcitx.Fcitx5.AnyTalk.Overlay ToggleRecording"))
-- 语音输入
hl.bind(mainMod .. " + SHIFT + Q",    hl.dsp.exec_cmd("busctl --user call org.fcitx.Fcitx5.AnyTalk.Overlay /overlay org.fcitx.Fcitx5.AnyTalk.Overlay ToggleRecording"))

-- 光标放大
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]))

-- 光标缩小
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 0.9 | if . < 1 then 1 else . end'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]) )

-- 缩放增大
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/scale.sh +"))
-- 缩放减小
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/scale.sh -"))

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
--   组合示例: "SUPER + SHIFT + Q"  "CTRL + ALT + left"
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
--     description = "说明", -- 描述文本
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

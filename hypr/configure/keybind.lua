-- ============================================================================
-- 快捷键绑定模块
-- ============================================================================
-- hl.bind(keys, dispatcher, opts?)
--   keys      : 修饰键组合，如 "SUPER + Q"（+ 两侧空格可选）
--   dispatcher: hl.dsp.* 返回的 dispatcher 闭包
--   opts      : { locked, release, repeating, click, ... }
-- hl.define_submap(name, reset?, fn) — 定义子映射
-- ============================================================================

local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"

-- 程序启动 ----------------------------------------------------------------
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- 焦点移动 ----------------------------------------------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- 工作区切换（数字键 1~0 对应 1~10）--------------------------------------
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- 窗口移动到工作区 ---------------------------------------------------------
for i = 1, 9 do
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- 特殊工作区（草稿箱/Scratchpad）------------------------------------------
hl.bind(mainMod .. " + S",                    hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",            hl.dsp.window.move({ workspace = "special:magic" }))

-- 滚轮切换已有工作区 -------------------------------------------------------
hl.bind(mainMod .. " + mouse_down",           hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + mouse_up",             hl.dsp.focus({ workspace = "-1" }))

-- 鼠标拖拽操作 -------------------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),  { description = "move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "resize window" })

-- 多媒体键（锁屏下可用 + 松手触发）----------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),      { locked = true, release = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),            { locked = true, release = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true, release = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),        { locked = true, release = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                       { locked = true, release = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                      { locked = true, release = true })

-- 媒体播放控制（锁屏下可用）------------------------------------------------
hl.bind("XF86AudioNext",   hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",   hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",   hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- 截图 ---------------------------------------------------------------------
hl.bind("Print",          hl.dsp.exec_cmd("screenshot region"))
hl.bind("SHIFT + Print",  hl.dsp.exec_cmd("screenshot full"))
hl.bind("CTRL + Print",   hl.dsp.exec_cmd("screenshot focused"))

-- 壁纸切换 -----------------------------------------------------------------
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/cycle-wallpaper.sh next"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.config/hypr/scripts/cycle-wallpaper.sh toggle"))

-- 语音输入（fcitx5-anytalk）------------------------------------------------
hl.bind("F2",                         hl.dsp.exec_cmd("busctl --user call org.fcitx.Fcitx5.AnyTalk.Overlay /overlay org.fcitx.Fcitx5.AnyTalk.Overlay ToggleRecording"))
hl.bind(mainMod .. " + SHIFT + Q",    hl.dsp.exec_cmd("busctl --user call org.fcitx.Fcitx5.AnyTalk.Overlay /overlay org.fcitx.Fcitx5.AnyTalk.Overlay ToggleRecording"))

-- 光标缩放（通过 hyprctl eval 热修改）----------------------------------------
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]))

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd([[NEW_VAL=$(hyprctl getoption cursor:zoom_factor -j | jq '.float * 0.9 | if . < 1 then 1 else . end'); hyprctl eval "hl.config({cursor={zoom_factor=$NEW_VAL}})"]]) )

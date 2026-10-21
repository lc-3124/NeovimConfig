-- HyprVim bootstrap shim
-- 源码在 ~/.local/share/hyprland/lua/plugins/hyprvim（git clone），
-- 这里只做转发，方便从 hyprland.lua 里 require("lua/plugins/hyprvim")。
local path = os.getenv("HOME")
  .. "/.local/share/hyprland/lua/plugins/hyprvim/init.lua"

local chunk, err = loadfile(path)

if not chunk then
  error(err)
end

return chunk()

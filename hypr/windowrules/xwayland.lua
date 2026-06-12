hl.window_rule({
    name = "fix-xwayland-drag",
    match = {
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
})

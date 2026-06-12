hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "waybar-float",
    match = { class = "Waybar" },
    float = true,
})

hl.window_rule({
    name = "dev-float",
    match = { title = ".*_demo_or_test.*" },
    float = true,
})

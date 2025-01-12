local icons = {{icon = "__base__/graphics/icons/pistol.png", tint = {0.3, 0.3, 0.3, 1}}}
data:extend{
  {
    type = "custom-input",
    name = "toggle-gun-range-visualizer",
    action = "lua",
    key_sequence = "CONTROL + SPACE",
  },
  {
    type = "shortcut",
    name = "toggle-gun-range-visualizer",
    icons = icons,
    small_icons = icons,
    action = "lua",
    associated_control_input = "toggle-gun-range-visualizer",
    order = "c[toggles]-c[gun-range]",
    toggleable = true,
  },
}

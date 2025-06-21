local mod_util = require("mod_util")

if mods.ModularLife then
  local function add_default_option(setting_name, new_option)
    local setting = data.raw["string-setting"][setting_name]
    if setting and type(setting.allowed_values) == "table" then
      setting.default_value = new_option
      table.insert(setting.allowed_values, 2, new_option)
    end
  end
  add_default_option("modLife-armorEquipmentGrid-light", "small-simple-equipment-grid")
  add_default_option("modLife-armorEquipmentGrid-heavy", "large-simple-equipment-grid")

  local setting = data.raw["string-setting"]["modLife-armorEquipmentGrid-modular"]
  if setting and type(setting.allowed_values) == "table" and mod_util.find(setting.allowed_values, function(v) return v == "4x6-grid" end) then
    setting.default_value = "4x6-grid"
    mod_util.set_optional(data.raw["bool-setting"]["even-modular-armor-grid"], "hidden", true)
  end
end

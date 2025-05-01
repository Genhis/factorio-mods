local mod_util = require("mod_util")

local function set_sound_speed(parent, key, value)
  if key == "filename" then
    parent.speed = 0.5
  end
end

local tint = {0.8, 0.537, 0.396}
local function replace_tint(parent, key, value)
  if key == "filename" then
    parent.tint = tint
  end
end

local function replace_entity_names(parent, key, value)
  if key ~= "type" and value == "construction-robot" then
    parent[key] = "early-construction-robot"
  elseif value == "construction-robot-dying-particle" then
    parent[key] = "early-construction-robot-dying-particle"
  elseif value == "construction-robot-explosion" then
    parent[key] = "early-construction-robot-explosion"
  elseif value == "construction-robot-metal-particle-medium" then
    parent[key] = "early-construction-robot-metal-particle-medium"
  elseif value == "construction-robot-metal-particle-small" then
    parent[key] = "early-construction-robot-metal-particle-small"
  elseif value == "construction-robot-remnants" then
    parent[key] = "early-construction-robot-remnants"
  elseif value == "entity-name.construction-robot" then
    parent[key] = "entity-name.early-construction-robot"
  end
end

local function make_copy(type, name, pictures_key)
  local prototype = mod_util.deepcopy_optional(data.raw[type], name)
  mod_util.iterate_recursive(prototype, replace_entity_names)
  mod_util.iterate_recursive(prototype and prototype[pictures_key], replace_tint)
  return prototype
end

-- early construction robot
mod_util.set_optional(data.raw.item["logistic-robot"], "order", "a[robot]-b[logistic-robot]")

local item = table.deepcopy(data.raw.item["construction-robot"])
mod_util.iterate_recursive(item, replace_entity_names)
item.order = "a[robot]-a"
mod_util.set_icon_tint(item, tint)

local entity = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
mod_util.iterate_recursive(entity, replace_entity_names)
entity.icons = item.icons
entity.energy_per_move = "2kJ"
entity.energy_per_tick = "0.04kJ"
entity.factoriopedia_simulation = {
  init = [[
    game.simulation.camera_position = {0, -1}
    game.surfaces[1].create_entity{name = "early-construction-robot", position = {0, 0}}
  ]]
}
entity.max_energy = "400kJ"
entity.max_health = (entity.max_health or 10) / 2
entity.max_speed = entity.speed

mod_util.iterate_recursive(entity.idle, replace_tint)
mod_util.iterate_recursive(entity.in_motion, replace_tint)
mod_util.iterate_recursive(entity.working, replace_tint)

mod_util.iterate_recursive(entity.charging_sound, set_sound_speed)
entity.mined_sound = "__core__/sound/deconstruct-robot.ogg"
mod_util.iterate_recursive(entity.working_sound, set_sound_speed)
mod_util.set_optional(entity.working_sound, "probability", 1 / 30 / second)

data:extend{
  entity,
  item,
  make_copy("corpse", "construction-robot-remnants", "animation"),
  make_copy("explosion", "construction-robot-explosion"),
  make_copy("optimized-particle", "construction-robot-dying-particle", "pictures"),
  make_copy("optimized-particle", "construction-robot-metal-particle-medium", "pictures"),
  make_copy("optimized-particle", "construction-robot-metal-particle-small", "pictures"),
  {
    type = "recipe",
    name = "early-construction-robot",
    enabled = false,
    energy_required = 2,
    ingredients = {
      {type = "item", name = "copper-plate", amount = 10},
      {type = "item", name = "electronic-circuit", amount = 2},
      {type = "item", name = "iron-gear-wheel", amount = 6},
    },
    results = {{type = "item", name = "early-construction-robot", amount = 1}},
  },
}

-- early personal roboport
local original = data.raw.item["personal-roboport-mk2-equipment"]
original.order = "a" .. original.order
local original = data.raw.item["personal-roboport-equipment"]
original.order = "a" .. original.order
local item = table.deepcopy(original)
item.name = "early-personal-roboport-equipment"
mod_util.set_icon_tint(item, tint)
item.place_as_equipment_result = "early-personal-roboport-equipment"

local equipment = table.deepcopy(data.raw["roboport-equipment"]["personal-roboport-equipment"])
equipment.name = "early-personal-roboport-equipment"
equipment.localised_description = {"item-description.personal-roboport-equipment"}
equipment.categories = {"simple-armor"}
equipment.charging_energy = "120kW"
equipment.construction_radius = 8
equipment.energy_source = {
  type = "electric",
  buffer_capacity = "4MJ",
  input_flow_limit = "240kW",
  usage_priority = "secondary-input",
}
equipment.recharging_animation = {
  filename = "__base__/graphics/entity/smoke-fast/smoke-general.png",
  width = 50,
  height = 50,
  animation_speed = 0.5,
  frame_count = 16,
  scale = 1,
}
equipment.shape = {type = "full", width = 2, height = 2}
equipment.sprite.tint = tint
equipment.take_result = nil

data:extend{
  equipment,
  item,
  {
    type = "recipe",
    name = "early-personal-roboport-equipment",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {type = "item", name = "copper-plate", amount = 20},
      {type = "item", name = "electronic-circuit", amount = 8},
      {type = "item", name = "iron-gear-wheel", amount = 16},
      {type = "item", name = "iron-plate", amount = 20},
    },
    results = {{type = "item", name = "early-personal-roboport-equipment", amount = 1}},
  },
}

-- burner generator equipment
local item = table.deepcopy(item)
item.name = "burner-generator-equipment"
item.order = "a[energy-source]-a[burner-generator-equipment]"
item.subgroup = "equipment"
item.icons = {{icon = "__base__/graphics/icons/boiler.png", tint = tint}}
item.place_as_equipment_result = "burner-generator-equipment"

local equipment = table.deepcopy(equipment)
equipment.type = "generator-equipment"
equipment.name = "burner-generator-equipment"
equipment.localised_description = nil
equipment.burner = {
  type = "burner",
  effectivity = 0.4,
  emissions_per_minute = {pollution = 20},
  fuel_categories = {"chemical"},
  fuel_inventory_size = 2,
}
equipment.energy_source = {
  type = "electric",
  usage_priority = "secondary-output",
}
equipment.power = "240kW"
equipment.sprite = {
  filename = "__base__/graphics/icons/boiler.png",
  width = 64,
  height = 64,
  tint = tint,
}

data:extend{
  equipment,
  item,
  {
    type = "recipe",
    name = "burner-generator-equipment",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {type = "item", name = "boiler", amount = 2},
      {type = "item", name = "copper-plate", amount = 20},
      {type = "item", name = "iron-gear-wheel", amount = 8},
      {type = "item", name = "iron-plate", amount = 20},
    },
    results = {{type = "item", name = "burner-generator-equipment", amount = 1}},
  },
}

-- equipment grids
for _, equipment_grid in pairs(data.raw["equipment-grid"]) do
  table.insert(equipment_grid.equipment_categories, "simple-armor")
end

local icons = util.technology_icon_constant_equipment("__base__/graphics/technology/personal-roboport-equipment.png")
icons[1].tint = tint
data:extend{
  {
    type = "equipment-category",
    name = "simple-armor",
  },
  {
    type = "equipment-grid",
    name = "small-simple-equipment-grid",
    equipment_categories = {"simple-armor"},
    width = 4,
    height = 2,
  },
  {
    type = "equipment-grid",
    name = "large-simple-equipment-grid",
    equipment_categories = {"simple-armor"},
    width = 4,
    height = 4,
  },
  {
    type = "technology",
    name = "early-personal-roboport-equipment",
    icons = icons,
    effects = {
      {type = "unlock-recipe", recipe = "early-construction-robot"},
      {type = "unlock-recipe", recipe = "early-personal-roboport-equipment"},
      {type = "unlock-recipe", recipe = "burner-generator-equipment"},
      {type = "create-ghost-on-entity-death", modifier = true},
    },
    prerequisites = {"automation-science-pack"},
    unit = {
      count = 30,
      ingredients = {{"automation-science-pack", 1}},
      time = 15,
    },
  },
}

data.raw.armor["light-armor"].equipment_grid = "small-simple-equipment-grid"
data.raw.armor["heavy-armor"].equipment_grid = "large-simple-equipment-grid"

if mod_util.get_optional(settings.startup["even-modular-armor-grid"], "value") then
  local equipment_grid = data.raw["equipment-grid"]["small-equipment-grid"]
  mod_util.set_optional(equipment_grid, "width", 6)
  mod_util.set_optional(equipment_grid, "height", 4)
end

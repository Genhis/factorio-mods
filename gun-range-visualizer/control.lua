local util = require("util")

local function has_elements(dict)
  for k, v in pairs(dict) do
    return true
  end
  return false
end

local function range_modifier(quality)
  return math.min(1 + quality.level * 0.1, 3)
end

local logic = {}

-- immutable data
local cache = {}
cache.ammo_inventory_mapping = {
  car = defines.inventory.car_ammo,
  character = defines.inventory.character_ammo,
  ["spider-vehicle"] = defines.inventory.spider_ammo,
}

cache.ammo_range_mapping_none = {id = -1, max = math.huge, multiplier = 1}
cache.ammo_range_mapping_default = {id = 0, max = math.huge, multiplier = 1}
cache.ammo_range_mapping = (function()
  local ammo_range_mapping = {}
  local next_id = 1
  for name, prototype in pairs(prototypes.get_item_filtered{{filter = "type", type = "ammo"}}) do
    local ammo_type = prototype.get_ammo_type()
    local smallest_max_range = math.huge
    for _, action in pairs(ammo_type.action or {}) do
      for _, action_delivery in pairs(action.action_delivery or {}) do
        if action_delivery.type == "projectile" then
          smallest_max_range = math.min(smallest_max_range, action_delivery.max_range)
        end
      end
    end
    
    if ammo_type.range_modifier ~= 1 or smallest_max_range ~= math.huge then
      ammo_range_mapping[name] = {
        id = next_id,
        max = smallest_max_range,
        multiplier = ammo_type.target_type == "direction" and smallest_max_range ~= math.huge and 2^52 or ammo_type.range_modifier, -- don't return math.huge because it can produce NaN when multiplied by zero
      }
      next_id = next_id + 1
    end
  end
  return ammo_range_mapping
end)()

cache.gun_empty = {
  prototype = {attack_parameters = {range = 0}},
  quality = prototypes.quality.normal,
}

-- utility functions
function logic.create_overlay(player_index, target)
  return rendering.draw_circle{
    color = {},
    draw_on_ground = true,
    filled = true,
    radius = 1,
    surface = target.surface,
    players = {player_index},
    target = target,
  }
end

function logic.get_color(data)
  return util.premul_color(data.player.mod_settings[data.last_range_id == cache.ammo_range_mapping_none.id and "gun-range-visualizer-no-ammo-color" or "gun-range-visualizer-color"].value)
end

function logic.get_selected_gun(entity)
  if entity.selected_gun_index == nil then
    return nil
  elseif entity.type == "car" or entity.type == "spider-vehicle" then
    return {prototype = entity.prototype.indexed_guns[entity.selected_gun_index], quality = entity.quality}
  elseif entity.type == "character" then
    local item_stack = entity.get_inventory(defines.inventory.character_guns)[entity.selected_gun_index]
    return item_stack.valid_for_read and {prototype = item_stack.prototype, quality = item_stack.quality} or cache.gun_empty
  end
end

-- aux logic
function logic.toggle(e)
  local activate = not storage.enabled_players[e.player_index]
  local player = game.players[e.player_index]
  player.set_shortcut_toggled("toggle-gun-range-visualizer", activate)
  storage.enabled_players[e.player_index] = activate or nil
  
  if activate then
    logic.start_ticking(player)
  else
    logic.stop_ticking(e)
  end
end

function logic.start_ticking(player)
  local data = {player = player}
  if logic.update_player(data) then
    storage.ticking_players[player.index] = data
    logic.check_tick_handler()
  end
end

function logic.stop_ticking(e)
  local data = storage.ticking_players[e.player_index]
  if data then
    if data.overlay and data.overlay.valid then
      data.overlay.destroy()
    end
    storage.ticking_players[e.player_index] = nil
    logic.check_tick_handler()
  end
end

function logic.refresh(e)
  if storage.enabled_players[e.player_index] then
    logic.start_ticking(game.players[e.player_index])
  end
end

-- main logic
function logic.update_player(data)
  local player = data.player
  local target = player.vehicle or player.controller_type == defines.controllers.character and player.character
  local gun = target and logic.get_selected_gun(target)
  if (not target) or (not gun) then
    if data.overlay and data.overlay.valid then
      data.overlay.destroy()
    end
    return false
  end

  if (not data.overlay) or (not data.overlay.valid) then
    data.overlay = logic.create_overlay(player.index, target)
  elseif data.overlay.surface ~= target.surface then
    data.overlay.destroy()
    data.overlay = logic.create_overlay(player.index, target)
  else
    data.overlay.target = target
  end

  local attack_parameters = gun.prototype.attack_parameters
  data.gun_projectile_offset = attack_parameters.projectile_creation_distance or 0
  data.gun_quality_multiplier = range_modifier(gun.quality)
  data.gun_range = attack_parameters.range
  data.last_range_id = nil
  data.selected_ammo_slot = target.get_inventory(cache.ammo_inventory_mapping[target.type])[target.selected_gun_index]
  data.selected_gun_index = target.selected_gun_index
  data.target = target
  logic.update_radius(data)
  return true
end

function logic.update_radius(data)
  local ammo_item_stack = data.selected_ammo_slot
  local ammo_range = ammo_item_stack.valid_for_read and (cache.ammo_range_mapping[ammo_item_stack.name] or cache.ammo_range_mapping_default) or cache.ammo_range_mapping_none
  if data.last_range_id ~= ammo_range.id then
    data.last_range_id = ammo_range.id
    data.overlay.color = logic.get_color(data)
    data.overlay.radius = math.min(data.gun_range * ammo_range.multiplier, ammo_range.max) * data.gun_quality_multiplier + data.gun_projectile_offset
  end
end

function logic.check_tick_handler()
  script.on_nth_tick(4, has_elements(storage.ticking_players) and logic.on_tick or nil)
end

function logic.on_tick(e)
  for key, data in pairs(storage.ticking_players) do
    if data.overlay.valid and data.target.valid and data.selected_gun_index == data.target.selected_gun_index then
      logic.update_radius(data)
    elseif not logic.update_player(data) then
      storage.ticking_players[key] = nil
      logic.check_tick_handler()
    end
  end
end

-- events
script.on_init(function()
  storage.enabled_players = {}
  storage.ticking_players = {}
end)

script.on_load(logic.check_tick_handler)
script.on_configuration_changed(function()
  -- This will force-refresh the selected gun. The event is only relevant in singleplayer because multiplayer raises player joined/left events.
  for _, data in pairs(storage.ticking_players) do
    data.selected_gun_index = -1
  end
end)

script.on_event(defines.events.on_player_joined_game, logic.refresh)
script.on_event(defines.events.on_player_left_game, logic.stop_ticking)
script.on_event(defines.events.on_player_removed, function(e) storage.enabled_players[e.player_index] = nil end)

script.on_event("toggle-gun-range-visualizer", logic.toggle)
script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "toggle-gun-range-visualizer" then
    logic.toggle(e)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  local data = storage.ticking_players[e.player_index]
  if data and data.overlay and data.overlay.valid and (e.setting == "gun-range-visualizer-color" or e.setting == "gun-range-visualizer-no-ammo-color") then
    data.overlay.color = logic.get_color(data)
  end
end)

script.on_event(
  {
    defines.events.on_player_changed_surface,
    defines.events.on_player_controller_changed,
    defines.events.on_player_driving_changed_state,
    defines.events.on_player_gun_inventory_changed,
  },
  function(e)
    local data = storage.ticking_players[e.player_index]
    if data then
      logic.update_player(data)
    else
      logic.refresh(e)
    end
  end
)

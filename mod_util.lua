local mod_util = {}

function mod_util.icon_to_icons(prototype)
  if not prototype.icons then
    prototype.icons = {{icon = prototype.icon, icon_size = prototype.icon_size}}
    prototype.icon = nil
    prototype.icon_size = nil
  end
end

function mod_util.set_icon_tint(prototype, tint)
  mod_util.icon_to_icons(prototype)
  for _, icon in pairs(prototype.icons) do
    icon.tint = tint
  end
end

function mod_util.iterate_recursive(value, callback, parent, key)
  if (not callback(parent, key, value)) and type(value) == "table" then
    for k, v in pairs(value) do
      mod_util.iterate_recursive(v, callback, value, k)
    end
  end
end

function mod_util.get_optional(parent, key)
  return parent and parent[key]
end

function mod_util.set_optional(parent, key, value)
  if type(parent) == "table" then
    parent[key] = value
  end
end

function mod_util.deepcopy_optional(parent, key)
  if parent and type(parent[key]) == "table" then
    return table.deepcopy(parent[key])
  end
end

function mod_util.find(t, comparator)
  for k, v in pairs(t) do
    if comparator(v) then
      return k
    end
  end
end

return mod_util

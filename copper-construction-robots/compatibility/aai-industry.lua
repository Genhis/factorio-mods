if not mods["aai-industry"] then return end

local function add_ingredient(recipe, ingredient)
  if recipe and recipe.ingredients then
    table.insert(recipe.ingredients, ingredient)
  end
end

local function add_prerequisite(technology, prerequisite)
  if technology then
    technology.prerequisites = technology.prerequisites or {}
    table.insert(technology.prerequisites, prerequisite)
  end
end

data.raw.recipe["burner-generator-equipment"].ingredients = {
  {type = "item", name = "copper-plate", amount = 20},
  {type = "item", name = "iron-plate", amount = 16},
  {type = "item", name = "motor", amount = 8},
  {type = "item", name = "stone-brick", amount = 5},
}
data.raw.recipe["early-construction-robot"].ingredients = {
  {type = "item", name = "copper-plate", amount = 12},
  {type = "item", name = "iron-gear-wheel", amount = 4},
  {type = "item", name = "motor", amount = 2},
}
data.raw.recipe["early-personal-roboport-equipment"].ingredients = {
  {type = "item", name = "copper-plate", amount = 32},
  {type = "item", name = "iron-gear-wheel", amount = 8},
  {type = "item", name = "iron-plate", amount = 20},
  {type = "item", name = "motor", amount = 8},
}

add_ingredient(data.raw.recipe["construction-robot"], {type = "item", name = "early-construction-robot", amount = 1})
add_ingredient(data.raw.recipe["personal-roboport-equipment"], {type = "item", name = "early-personal-roboport-equipment", amount = 1})
add_ingredient(data.raw.recipe["fission-reactor-equipment"], {type = "item", name = "burner-generator-equipment", amount = 1})
add_prerequisite(data.raw.technology["construction-robotics"], "early-personal-roboport-equipment")

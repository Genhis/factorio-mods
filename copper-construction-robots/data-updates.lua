for _, equipment_grid in pairs(data.raw["equipment-grid"]) do
  table.insert(equipment_grid.equipment_categories, "simple-armor")
end

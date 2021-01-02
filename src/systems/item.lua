local ItemSystem = Concord.system({ pool = { "item" }})

function ItemSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity:give("interactable", "Press c to pick up", { name = "pickItemUp", props = { entity }}, "pickup")
  end

  self.pool.onEntityRemoved = function(_, entity)
    entity:remove("interactable")
  end
end

function ItemSystem:pickItemUp(newOwner, itemEntity)
  if not newOwner.inventory then
    error("Tried to pick item up with no inventory")
  end

  itemEntity:remove("position")
  itemEntity:give("inInventory", newOwner.inventory.entityId)
end
--
-- function ItemSystem:moveItemToInventory(picker, item)
--   item:remove("position")
--   item:give("inInventory", picker.id.value)
-- end
--

return ItemSystem

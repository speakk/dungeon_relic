local ItemSystem = Concord.system({ pool = { "item" }})

function ItemSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity:give("interactable", "Press c to pick up", { name = "pickItemUp", props = { entity }}, "pickup")
  end

  self.pool.onEntityRemoved = function(_, entity)
    entity:remove("interactable")
  end
end

function ItemSystem:pickItemUp(newOwner, itemEntity) --luacheck: ignore
  if not newOwner.inventory then
    error("Tried to pick item up with no inventory")
  end

  itemEntity:remove("position")
  itemEntity:give("inInventory", newOwner.inventory.entityId)
end

function ItemSystem:dropItem(owner, itemEntity) -- luacheck: ignore
  print("Dropping item")
  itemEntity:remove("inInventory")
  itemEntity:give("position", Vector.split(owner.position.vec))
end

return ItemSystem

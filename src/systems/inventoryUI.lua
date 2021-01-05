local Gamestate = require 'libs.hump.gamestate'

local inventoryState = require 'states.inventory'

local InventoryUISystem = Concord.system({ pool = { "playerControlled", "inventory" }, itemsInInventory = { "item", "inInventory" }})

function InventoryUISystem:init()
  self.pool.onEntityAdded = function(_, entity)
    self.inventoryId = entity.inventory.entityId
    self.player = entity
  end
end

local function dropItem(world, owner, item)
  world:emit("dropItem", owner, item)
end

function InventoryUISystem:showInventory()
  local inPlayerInventory = functional.filter(self.itemsInInventory, function(itemEntity)
    return itemEntity.inInventory.inventoryId == self.inventoryId
  end)

  print("inPlayerInventory length", #inPlayerInventory)

  Gamestate.push(inventoryState, self.player, inPlayerInventory, self:getWorld(), dropItem)
end

return InventoryUISystem

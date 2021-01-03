local InventoryUISystem = Concord.system({ pool = { "playerControlled", "inventory" }, itemsInInventory = { "item", "inInventory" }})

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

function InventoryUISystem:init()
  self.pool.onEntityAdded = function(_, entity)
    self.inventoryId = entity.inventory.entityId
  end
end

function InventoryUISystem:drawInventory()
  local inPlayerInventory = functional.filter(self.itemsInInventory, function(itemEntity)
    return itemEntity.inInventory.inventoryId == self.inventoryId
  end)

  local x = 800
  local y = 10
  local maxWidth = 100
  for _, itemEntity in ipairs(inPlayerInventory) do
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(itemEntity.displayName.value, font, x, y, maxWidth)
    local mediaEntity = mediaManager:getMediaEntity(itemEntity.sprite.spriteId)
    local atlasImage = mediaManager:getAtlas("autoLoaded"):getImage()
    local quad = mediaEntity.quads[itemEntity.sprite.currentQuadIndex]
    love.graphics.draw(atlasImage, quad, x + maxWidth, y)
  end
end

function InventoryUISystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "ui", self.drawInventory, self, false)
end

return InventoryUISystem

local EquipmentUISystem = Concord.system( { players = { "playerControlled", "inventory", "equipmentSlots" }, items = { "item", "equippable", "inInventory" } })

function EquipmentUISystem:init()
  self.players.onEntityAdded = function(_, entity)
    self.playerInventoryId = entity.inventory.entityId
    self.slots = entity.equipmentSlots.slots
    self.player = entity
  end
end

local slotPlacement = {
  headArmor = { 0.5, 0 },
  rightHandArmor = { 0.25, 0.5 },
  rightHandWeapon = { 0.0, 0.5 },
  torso = { 0.5, 0.5 },
  leftHandArmor = { 0.75, 0.5 },
  leftHandWeapon = { 1.0, 0.5 },
  rightLegArmor = { 0.25, 1.0 },
  leftLegArmor = { 0.75, 1.0 },
}

local getPos = function(slot,containerX,containerY,w,h, slotSize)
  local placement = slotPlacement[slot]
  local x = containerX + placement[1] * w - slotSize / 2
  local y = containerY + placement[2] * h - slotSize / 2
  return x, y
end

function EquipmentUISystem:draw()
  if not self.slots then return end
  local screenW,screenH = love.graphics.getDimensions()

  local paddingX,paddingY = 50, 50
  local w,h = 300, 250
  local x,y = screenW - w - paddingX, screenH - h - paddingY
  local scale = 2
  local slotSize = 32 * scale

  for _, slot in ipairs(self.slots) do
    local slotX, slotY = getPos(slot,x,y,w,h,slotSize)
    love.graphics.setColor(0.2,0.08,0.04)
    love.graphics.rectangle('fill', slotX, slotY, slotSize, slotSize)
    love.graphics.setColor(0.5,0.4,0.1)
    love.graphics.rectangle('line', slotX, slotY, slotSize, slotSize)
    love.graphics.setColor(1,1,1)

    local equippedInSlot = functional.filter(self.items, function(item)
      return item.equippable.equippedById == self.player.id.value and item.equippable.slot == slot
    end)

    if #equippedInSlot > 0 then
      local equippedItem = equippedInSlot[1]
      local mediaEntity = mediaManager:getMediaEntity(equippedItem.sprite.spriteId)
      local atlasImage = mediaManager:getAtlas("autoLoaded"):getImage()
      local quad = mediaEntity.quads[equippedItem.sprite.currentQuadIndex]
      love.graphics.draw(atlasImage, quad, slotX, slotY, 0, scale, scale)
    end
  end
end

return EquipmentUISystem

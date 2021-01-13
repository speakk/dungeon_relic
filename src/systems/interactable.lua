local inGame = require 'states.inGame'

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

local InteractableSystem = Concord.system({ interactable = { "interactable" }, interacter = { "interacter" }})

function InteractableSystem:update(dt)
  for _, entity in ipairs(self.interactable) do
    entity.interactable.active = false
  end

  for _, entity in ipairs(self.interacter) do
    local x, y = Vector.split(entity.position.vec)
    local range = entity.interacter.range
    inGame.spatialHash.interactable:each(x - range / 2, y - range / 2, range / 2, range / 2, function(interactableEntity)
      local interactable = interactableEntity.interactable
      local distance = (entity.position.vec - interactableEntity.position.vec).length
      if distance < interactable.range then
        interactableEntity.interactable.active = true
      end
    end)
  end
end

function InteractableSystem:init()
  self.cameraX, self.cameraY = 0, 0
  self.cameraScale = 1
end

function InteractableSystem:cameraUpdated(camera)
  self.cameraX, self.cameraY = camera:getPosition()
  self.camera = camera
  self.cameraScale = camera:getScale()
end

function InteractableSystem:drawTooltips()
  for _, entity in ipairs(self.interactable) do
    local interactable = entity.interactable
    if interactable.active then
      entity.sprite.outline = true
      local x, y = Vector.split(entity.position.vec)
      local finalX, finalY = self.camera:toScreen(x, y)
      local maxWidth = 100
      love.graphics.setColor(1,1,1,1)
      love.graphics.printf(interactable.tooltip, font, finalX, finalY, maxWidth, 'center')
    else
      entity.sprite.outline = false
    end
  end
end

function InteractableSystem:interactIntent(entity, category)
  local x, y = Vector.split(entity.position.vec)
  local range = entity.interacter.range
  inGame.spatialHash.interactable:each(x - range / 2, y - range / 2, range / 2, range / 2, function(interactableEntity)
    local distance = (entity.position.vec - interactableEntity.position.vec).length
    local interactable = interactableEntity.interactable
    if distance < interactable.range then
      local event = interactable.event
      if interactable.category == category then
        self:getWorld():emit(event.name, entity, event.props and unpack(event.props) or nil)
      end
    end
  end)
end

function InteractableSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "tooltips", self.drawTooltips, self, false)
end

return InteractableSystem

local Gamestate = require 'libs.hump.gamestate'

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

local InteractableSystem = Concord.system({ interactable = { "interactable" }, interacter = { "interacter" }})

function InteractableSystem:update(dt)
  for _, entity in ipairs(self.interactable) do
    entity.interactable.active = false
  end

  for _, entity in ipairs(self.interacter) do
    local x, y = Vector.split(entity.position.vec)
    local range = entity.interacter.range
    Gamestate.current().spatialHash.interactable:each(x - range / 2, y - range / 2, range / 2, range / 2, function(interactableEntity)
      interactableEntity.interactable.active = true
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
      local x, y = Vector.split(entity.position.vec)
      local finalX, finalY = self.camera:toScreen(x, y)
      local maxWidth = 100
      love.graphics.setColor(1,1,1,1)
      love.graphics.printf(interactable.tooltip, font, finalX, finalY, maxWidth, 'center')
    end
  end
end

function InteractableSystem:interactIntent(entity)
  local x, y = Vector.split(entity.position.vec)
  local range = entity.interacter.range
  Gamestate.current().spatialHash.interactable:each(x - range / 2, y - range / 2, range / 2, range / 2, function(interactableEntity)
    local interactable = interactableEntity.interactable
    self:getWorld():emit(interactable.event.name, interactable.event.props)
  end)
end

function InteractableSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "tooltips", self.drawTooltips, self, false)
end

return InteractableSystem
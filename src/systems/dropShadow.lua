local DropShadowSystem = Concord.system({ pool = { "dropShadow" }})
local settings = require 'settings'

function DropShadowSystem:draw()
  love.graphics.setColor(0,0,0,0.2)
  for _, entity in ipairs(self.pool) do
    local pos = entity.position.vec - Vector(settings.spritePadding, settings.spritePadding)
    love.graphics.ellipse('fill', pos.x, pos.y, 13, 8)
    love.graphics.ellipse('fill', pos.x, pos.y, 10, 5)
    love.graphics.ellipse('fill', pos.x, pos.y, 5, 3)
  end
  love.graphics.setColor(1,1,1,1)
end

function DropShadowSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "onGround", self.draw, self, true)
end

return DropShadowSystem

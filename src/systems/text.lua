local TextSystem = Concord.system( { pool = { "text", "position" } } )
local inGame = require 'states.inGame'

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 36)

function TextSystem:drawPool()
  love.graphics.setColor(1,1,1,1)
  for _, entity in ipairs(self.pool) do
    local textWidth = entity.text.textWidth or 300
    local x, y = Vector.split(entity.position.vec)
    local finalX, finalY = inGame.camera:toScreen(x, y)
    print("Drawing", entity.text.value, finalX, finalY)
    love.graphics.printf(entity.text.value, font, finalX, finalY, textWidth)
  end
end

function TextSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "tooltips", self.drawPool, self, false)
end

return TextSystem

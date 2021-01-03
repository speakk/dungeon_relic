local Gamestate = require 'libs.hump.gamestate'
local state = {}

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

function state:enter(previousState, items) --luacheck: ignore
  self.items = items
  self.previousState = previousState
end

function state:keypressed(pressedKey) --luacheck: ignore
  if pressedKey == 'tab' then
    Gamestate.pop()
  end
end

function state:update(dt)
  self.previousState:update(dt)
end

function state:draw()
  self.previousState:draw()
  local x = 800
  local y = 10
  local maxWidth = 100
  for _, itemEntity in ipairs(self.items) do
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(itemEntity.displayName.value, font, x, y, maxWidth)
    local mediaEntity = mediaManager:getMediaEntity(itemEntity.sprite.spriteId)
    local atlasImage = mediaManager:getAtlas("autoLoaded"):getImage()
    local quad = mediaEntity.quads[itemEntity.sprite.currentQuadIndex]
    love.graphics.draw(atlasImage, quad, x + maxWidth, y)
  end
end

return state


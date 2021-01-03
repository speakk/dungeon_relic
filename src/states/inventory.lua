local Gamestate = require 'libs.hump.gamestate'
local flux = require 'libs.flux'
local settings = require 'settings'
local state = {}

local outlineShader = love.graphics.newShader('src/shaders/outline.fs')

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

function state:enter(previousState, items) --luacheck: ignore
  local _, screenH = love.graphics.getDimensions()
  self.offsetY = -screenH - 100
  flux.to(self, 1, { offsetY = 0 }):ease("quintout")
  self.items = items
  self.previousState = previousState
end

function state:keypressed(pressedKey) --luacheck: ignore
  if pressedKey == 'tab' then
    -- local _, screenH = love.graphics.getDimensions()
    -- = flux.to(self, 0.3, { offsetY = -screenH - 100 }):ease("quintout")
    -- :oncomplete(function()
    --   self:draw()
    --   self.previousState:draw()
    --   Gamestate.pop()
    -- end)
    Gamestate.pop()
  end
end

function state:update(dt)
  flux.update(dt)
  --self.previousState:update(dt)
end

local function centerX(width)
  return love.graphics.getWidth() / 2 - width / 2
end

local function centerY(width)
  return love.graphics.getHeight() / 2 - width / 2
end

local function drawBackground(self)
  local rectWidth = 600
  local rectHeight = 600
  local x = centerX(rectWidth)
  local y = centerY(rectHeight) + self.offsetY
  local rounding = 10
  love.graphics.setColor(0.2, 0.1, 0.1)
  love.graphics.rectangle('fill', x, y, rectWidth, rectHeight, rounding, rounding)
  love.graphics.setColor(0.26, 0.15, 0.16)
  love.graphics.rectangle('fill', x, y, rectWidth, rectHeight/2, rounding, rounding)
  love.graphics.setColor(0.8, 0.7, 0.6)
  love.graphics.rectangle('line', x, y, rectWidth, rectHeight, rounding, rounding)
  love.graphics.setColor(1,1,1)
end

local function drawItems(self)
  local textWidth = 100
  local scale = 2
  local x = centerX(textWidth + settings.tileSize * scale)
  local y = centerY(textWidth + settings.tileSize * scale) + self.offsetY
  for _, itemEntity in ipairs(self.items) do
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(itemEntity.displayName.value, font, x, y, textWidth)

    local mediaEntity = mediaManager:getMediaEntity(itemEntity.sprite.spriteId)
    local atlasImage = mediaManager:getAtlas("autoLoaded"):getImage()
    local quad = mediaEntity.quads[itemEntity.sprite.currentQuadIndex]
    local _, _, quadW, quadH = quad:getViewport()
    local thickness = 0.01
    if outlineShader:hasUniform("stepSize") then
      outlineShader:send( "stepSize",{thickness/quadW,thickness/quadH} )
    end
    love.graphics.setShader(outlineShader)
    love.graphics.draw(atlasImage, quad, x + textWidth, y, 0, scale, scale)
    love.graphics.setShader()
  end

end

function state:draw()
  self.previousState:draw()
  drawBackground(self)
  drawItems(self)
end

return state


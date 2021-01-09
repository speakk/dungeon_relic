local Gamestate = require 'libs.hump.gamestate'
local flux = require 'libs.flux'
local settings = require 'settings'
local state = {}

local outlineShader = love.graphics.newShader('src/shaders/outline.fs')

local font = love.graphics.newFont('media/fonts/TrueType/PixeloidSans.ttf', 18)

function state:enter(previousState, owner, items, world, dropItemsCallback) --luacheck: ignore
  local _, screenH = love.graphics.getDimensions()
  self.offsetY = -screenH - 100
  flux.to(self, 1, { offsetY = 0 }):ease("quintout")

  self.owner = owner
  self.items = table.copy(items)
  self.world = world
  self.previousState = previousState
  self.selectedItemIndex = 1
  self.dropItemsCallback = dropItemsCallback
end

function state:keypressed(pressedKey) --luacheck: ignore
  if pressedKey == 'tab' then
    Gamestate.pop()
  end

  if pressedKey == 'down' then
    self:changeSelectedItem(1)
  end

  if pressedKey == 'up' then
    self:changeSelectedItem(-1)
  end

  if pressedKey == "d" then
    local item = self.items[self.selectedItemIndex]
    self.dropItemsCallback(self.world, self.owner, item)
    table.remove_value(self.items, item)
  end

  if pressedKey == "e" then
    local item = self.items[self.selectedItemIndex]
    if item.equippable then
      if item.equippable.equippedById == self.owner.id.value then
        item.equippable.equippedById = nil
      else
        item.equippable.equippedById = self.owner.id.value
      end
    end
  end
end

function state:changeSelectedItem(direction)
  print("index now", self.selectedItemIndex)
  self.selectedItemIndex = self.selectedItemIndex + direction
  if self.selectedItemIndex > #self.items then
    self.selectedItemIndex = 1
  elseif self.selectedItemIndex < 1 then
    self.selectedItemIndex = #self.items
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

local function drawBackground(self, width, height)
  local x = centerX(width)
  local y = centerY(height) + self.offsetY
  local rounding = 10
  love.graphics.setColor(0.2, 0.1, 0.1)
  love.graphics.rectangle('fill', x, y, width, height, rounding, rounding)
  love.graphics.setColor(0.26, 0.15, 0.16)
  love.graphics.rectangle('fill', x, y, width, height/2, rounding, rounding)
  love.graphics.setColor(0.8, 0.7, 0.6)
  love.graphics.rectangle('line', x, y, width, height, rounding, rounding)
  love.graphics.setColor(1,1,1)
end

local function drawItems(self, width, height)
  if #(self.items) == 0 then return end
  local textWidth = 100
  local scale = 2
  local x = centerX(textWidth + settings.tileSize * scale)
  local y = centerY(textWidth + settings.tileSize * scale) + self.offsetY
  local yOffset = 0
  local rowHeight = 34 * scale
  for i, itemEntity in ipairs(self.items) do
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(itemEntity.displayName.value, font, x, y + yOffset, textWidth)

    local mediaEntity = mediaManager:getMediaEntity(itemEntity.sprite.spriteId)
    local atlasImage = mediaManager:getAtlas("autoLoaded"):getImage()
    local quad = mediaEntity.quads[itemEntity.sprite.currentQuadIndex]
    local _, _, quadW, quadH = quad:getViewport()
    local thickness = 0.01
    if outlineShader:hasUniform("stepSize") then
      outlineShader:send( "stepSize",{thickness/quadW,thickness/quadH} )
    end
    love.graphics.setShader(outlineShader)
    love.graphics.draw(atlasImage, quad, x + textWidth, y+yOffset, 0, scale, scale)
    love.graphics.setShader()

    if i == self.selectedItemIndex then
      love.graphics.setColor(0.5,1,0.5)
      love.graphics.rectangle('line', centerX(width), y+yOffset, width, rowHeight)
      love.graphics.setColor(1,1,1,1)
    end


    yOffset = yOffset + rowHeight
  end
end

local function drawTooltip(self, width, height)
  if #(self.items) == 0 then return end
  local tooltipHeight = 90
  local yOffset = 0

  local getY = function()
    return self.offsetY + centerY(height) + height - tooltipHeight + yOffset
  end

  love.graphics.setColor(0.3,0.6,0.3)
  love.graphics.rectangle('line', centerX(width), getY(), width, tooltipHeight)
  love.graphics.setColor(1,1,1,1)

  local item = self.items[self.selectedItemIndex]
  if not item then return end

  local lineHeight = 15

  local textWidth = 200

  love.graphics.setColor(1,1,1,1)

  if item.equippable then
    love.graphics.printf("Press e to equip", font, centerX(width), getY(), textWidth)
    yOffset = yOffset + lineHeight
  end

  love.graphics.printf("Press d to drop", font, centerX(width), getY(), textWidth)
end

function state:draw()
  self.previousState:draw()
  local width = 600
  local height = 600
  drawBackground(self, width, height)
  drawItems(self, width, height)
  drawTooltip(self, width, height)
end

return state


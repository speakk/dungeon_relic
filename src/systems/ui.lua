local UISystem = Concord.system( { players = { "playerControlled", "health"} })

local healthBarImage = love.graphics.newImage('media/ui/healthbar.png')
local healthImgW, healthImgH = healthBarImage:getDimensions()

local imageScale = 3

function UISystem:init() --luacheck: ignore
  self.players.onEntityAdded = function(_, entity)
    functional.find_match(self.elements, function(element)
      element.value = entity.health.value
      element.maxValue = entity.health.maxHealth
    end)
  end

  self.elements = {
    {
      id = "healthBar",
      uiType = "bar",
      maxValue = 0,
      value = 0,
      color = { r = 0.7, g = 0.1, b = 0, a = 1 },
      colorBackground = { r = 0.5, g = 0, b = 0, a = 1 },
      padding = { x = 60, y = 60 },
      rounding = 30,
      overlayImage = healthBarImage,
      overlayImageOffset = { x = -10, y = 0 },
      anchor = "bottomLeft",
      width = {
        px = healthImgW * imageScale / 1.2
      },
      height = {
        px = healthImgH * imageScale / 1.4
      }
    }
  }
end

function UISystem:updateHealthBar(value, maxValue)
  local healthBar = functional.find_match(self.elements, function(element)
    return element.id == "healthBar"
  end)

  healthBar.value = value or healthBar.value
  if healthBar.value < 0 then healthBar.value = 0 end
  healthBar.maxValue = maxValue or healthBar.maxValue
end

function UISystem:healthChanged(target, newValue)
  if functional.contains(self.players, target) then
    self:updateHealthBar(newValue)
  end
end

function UISystem:update(dt)
end

local anchors = {
  bottomLeft = { "l", "b" },
}

local function getAnchorPosition(name, width, height, parent, padding)
  local paddingCopy = { x = padding.x or 0, y = padding.y or 0 }
  local anchorPoints = anchors[name] or error("No anchor by the name" .. name)
  local anchorX = anchorPoints[1]
  local anchorY = anchorPoints[2]
  local modX = 0
  local modY = 0
  if anchorX == "r" then
    modX = -width
    paddingCopy.x = -paddingCopy.x
  end
  if anchorY == "b" then
    modY = -height
    paddingCopy.y = -paddingCopy.y
  end
  local x = parent[anchorPoints[1]] + modX + paddingCopy.x
  local y = parent[anchorPoints[2]] + modY + paddingCopy.y
  return x, y
end

local uiTypeHandlers = {
  bar = function(element, x, y, width, height)
    if element.backgroundImage then
      love.graphics.draw(element.backgroundImage, x, y, 0, imageScale, imageScale)
    end

    local roundness = element.rounding or 10
    local colorB = element.colorBackground
    love.graphics.setColor(colorB.r, colorB.g, colorB.b, colorB.a)
    love.graphics.rectangle('fill', x, y, width, height, roundness, roundness)

    local colorA = element.color
    local valueWidth = width * element.value/element.maxValue

    -- Love rectangle bugs out with very narrow rectangle and rounded corners
    if roundness > valueWidth then
      roundness = 0
    end
    love.graphics.setColor(colorA.r, colorA.g, colorA.b, colorA.a)
    love.graphics.rectangle('fill', x, y, width * element.value/element.maxValue, height, roundness, roundness)

    if element.overlayImage then
      local imgW, imgH = element.overlayImage:getDimensions()
      imgW = imgW * imageScale
      imgH = imgH * imageScale
      local imgX = x + (width - imgW) / 2
      local imgY = y + (height - imgH) / 2
      if element.overlayImageOffset then
        imgX = imgX + element.overlayImageOffset.x
        imgY = imgY + element.overlayImageOffset.y
      end
      love.graphics.setColor(1,1,1,1)
      love.graphics.draw(element.overlayImage, imgX, imgY, 0, imageScale, imageScale)
    end
  end
}

function UISystem:drawUI()
  local winWidth, winHeight = love.graphics.getDimensions()

  for _, element in ipairs(self.elements) do
    local parent = element.parent
    if not parent then
      parent = { l = 0, t = 0, r = winWidth, b = winHeight }
    end

    local width = element.width.px
    if not width then
      width = parent.r * element.width.percentage/100
      local minWidth = element.width.minPx or width
      local maxWidth = element.width.maxPx or width
      width = math.clamp(width, minWidth, maxWidth)
    end
    local height = element.height.px
    if not height then
      height = parent.b * element.height.percentage/100
      local minHeight = element.height.minPx or height
      local maxHeight = element.height.maxPx or height
      height = math.clamp(height, minHeight, maxHeight)
    end
    local x, y = getAnchorPosition(element.anchor, width, height, parent, element.padding)
    uiTypeHandlers[element.uiType](element, x, y, width, height)
  end
end

return UISystem


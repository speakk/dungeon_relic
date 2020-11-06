local UISystem = Concord.system( { players = { "playerControlled", "health"} })

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
      color = { r = 1, g = 0, b = 0, a = 1 },
      colorBackground = { r = 0.5, g = 0, b = 0, a = 1 },
      anchor = "bottomLeft",
      width = {
        percentage = 30,
        minPx = 100
      },
      height = {
        px = 60
      }
    }
  }
end

function UISystem:updateHealthBar(value, maxValue)
  local healthBar = functional.find_match(self.elements, function(element)
    return element.id == "healthBar"
  end)

  healthBar.value = value or healthBar.value
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

local function getAnchorPosition(name, width, height, parent)
  local anchorPoints = anchors[name] or error("No anchor by the name" .. name)
  local anchorX = anchorPoints[1]
  local anchorY = anchorPoints[2]
  local modX = 0
  local modY = 0
  if anchorX == "r" then
    modX = -width
  end
  if anchorY == "b" then
    modY = -height
  end
  local x = parent[anchorPoints[1]] + modX
  local y = parent[anchorPoints[2]] + modY
  return x, y
end

local uiTypeHandlers = {
  bar = function(element, x, y, width, height)
    local roundness = 10
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
    local x, y = getAnchorPosition(element.anchor, width, height, parent)
    uiTypeHandlers[element.uiType](element, x, y, width, height)
  end
end

return UISystem


local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'
local Timer = require 'libs.hump.timer'

local GridCollisionSystem = Concord.system({ pool = { "gridCollisionItem" } })

local debugRectangles = {}

local function setCollisionValue(x, y, value, self)
  local mapManager = Gamestate.current().mapManager
  mapManager:setCollisionMapValue(
  x,
  y,
  value)

  self:updateCollisionTileMap()
end

local function mergeTilesIntoRectangles(map, tileSize)
  local function getSafe(twoDimTable, x, y)
    if twoDimTable[y] then
      return twoDimTable[y][x]
    else
      return nil
    end
  end

  local tiles = functional.generate(#map, function(y)
    return functional.generate(#map[1], function(x)
      return { rectangleId = nil, tileExists = getSafe(map, x, y) == 1 }
    end)
  end)

  local currentRectangleIdIndex = 0

  local function getNewRectangleId()
    currentRectangleIdIndex = currentRectangleIdIndex + 1
    return currentRectangleIdIndex
  end

  local rectangles = {}

  for y, row in ipairs(map) do
    for x, tileValue in ipairs(row) do
      if tileValue == 1 then
        local tile = getSafe(tiles, x, y)
        if tile.tileExists then
          local leftTile = getSafe(tiles, x - 1, y)
          if leftTile and leftTile.tileExists and leftTile.rectangleId then
            -- Extend rectangle on the left
            tile.rectangleId = leftTile.rectangleId
            rectangles[tile.rectangleId].endX = x
          else
            -- Start new rectangle
            tile.rectangleId = getNewRectangleId()
            rectangles[tile.rectangleId] = {
              startX = x, endX = x, startY = y, endY = y, id = tile.rectangleId
            }
          end
        end
      end
    end
  end

  local toBeMerged = table.copy(rectangles)

  -- Merge downwards when possible
  for _, rectangle in pairs(rectangles) do
    local rectanglesToBeMergedLeft = true

    while rectanglesToBeMergedLeft do
      -- Search toBeMerged here because we don't want to find a rectangle we've already deemed to be merged
      local rectangleBelow = functional.find_match(toBeMerged, function(otherRectangle)
        return otherRectangle.startY == rectangle.endY + 1 and
        otherRectangle.startX == rectangle.startX and otherRectangle.endX == rectangle.endX
      end)

      if rectangleBelow then
        -- Rectangle is identical in width so can merge
        rectangle.endY = rectangleBelow.endY
        table.remove_value(toBeMerged, rectangleBelow)
      else
        rectanglesToBeMergedLeft = false
      end
    end
  end

  return toBeMerged
end

local bufferLength = 1.0
local bufferTimer = nil
function GridCollisionSystem:updateCollisionTileMap()
  if bufferTimer then return end
  bufferTimer = Timer.after(bufferLength, function()
    bufferTimer = nil
    local collisionMap = Gamestate.current().mapManager:getCollisionMap()
    local tileRectangles = mergeTilesIntoRectangles(collisionMap, Gamestate.current().mapManager.map.tileSize)
    debugRectangles = tileRectangles

    local tileSize = Gamestate.current().mapManager.map.tileSize

    for _, rect in ipairs(tileRectangles) do
      local polygonTileCoords = {
        rect.startX, rect.startY,
        rect.endX + 1, rect.startY,
        rect.endX + 1, rect.endY + 1,
        rect.startX, rect.endY + 1
      }
      local polygon = functional.map(polygonTileCoords, function(coord) return coord*tileSize end)

      local entity = Concord.entity(self:getWorld())
      entity:give("position", rect.startX * tileSize, rect.startY * tileSize)
      entity:give("physicsBody", (rect.endX + 1 - rect.startX) * tileSize, (rect.endY + 1 - rect.startY) * tileSize, { "wall" }, nil, true)
    end
  end)
end

function GridCollisionSystem:drawDebugWithCamera()
  local tileSize = Gamestate.current().mapManager.map.tileSize
  for _, rect in ipairs(debugRectangles) do
    love.graphics.setColor(1,1,0)
    local polygonTileCoords = {
      rect.startX, rect.startY,
      rect.endX + 1, rect.startY,
      rect.endX + 1, rect.endY + 1,
      rect.startX, rect.endY + 1
    }
    local polygon = functional.map(polygonTileCoords, function(coord) return coord*tileSize end)
    love.graphics.polygon("line", polygon)
    love.graphics.setColor(1,0,0)
    love.graphics.printf(rect.id, rect.startX*tileSize, rect.startY*tileSize, 200)
    love.graphics.setColor(1,1,1)
  end
end

function GridCollisionSystem:init(_)
  self.pool.onEntityAdded = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 1, self)
  end

  self.pool.onEntityRemoved = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 0, self)
  end
end

return GridCollisionSystem

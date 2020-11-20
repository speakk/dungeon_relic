local Gamestate = require 'libs.hump.gamestate'
local Timer = require 'libs.hump.timer'

local GridCollisionSystem = Concord.system({ pool = { "gridCollisionItem" } })

-- For optimization purposes, merge individual tiles into bigger rectangles.
-- Steps through tiles one by one and checks if there's already a "rectangle"
-- on the left. If it exists, extend it. These rectangles can then be used
-- for collision instead of hundreds of individual tiles.
local function mergeTilesIntoRectangles(map)
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
  local individualRectangles = {}

  for y, row in ipairs(map) do
    for x, tileValue in ipairs(row) do
      if tileValue == 1 then
        local tile = getSafe(tiles, x, y)
        if tile.tileExists then
          table.insert(individualRectangles, { startX = x, endX = x, startY = y, endY = y })
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
  --return individualRectangles
end

function GridCollisionSystem:updateCollisionTileMap()
  if self.bufferTimer then return end
  self.bufferTimer = Timer.after(self.bufferLength, function()
    self.bufferTimer = nil

    for _, entity in ipairs(self.tileRectangleEntities) do
      entity:destroy()
    end

    local collisionMap = Gamestate.current().mapManager:getCollisionMap()
    local tileRectangles = mergeTilesIntoRectangles(collisionMap)

    local tileSize = Gamestate.current().mapManager.map.tileSize

    for _, rect in ipairs(tileRectangles) do
      local entity = Concord.entity(self:getWorld())
      entity:give("position", rect.startX * tileSize, rect.startY * tileSize)
      local width = (rect.endX + 1 - rect.startX) * tileSize
      local height = (rect.endY + 1 - rect.startY) * tileSize
      entity:give("physicsBody", {
        width = width,
        height = height,
        tags = { "wall" },
        static = true
      })
      entity:give("lightBlocker", width, height)
      entity:give("lightBlockerActive")
      table.insert(self.tileRectangleEntities, entity)
    end
  end)
end

local function setCollisionValue(x, y, value, self)
  local mapManager = Gamestate.current().mapManager
  mapManager:setCollisionMapValue(
  x,
  y,
  value)

  self:updateCollisionTileMap()
end

function GridCollisionSystem:init(_)
  self.tileRectangleEntities = {}

  -- Updating the collision rectangles from tile map is a heavy operation,
  -- so buffer consecutive calls to the function
  -- Used in function GridCollisionSystem:updateCollisionTileMap()
  self.bufferLength = 0.2
  self.bufferTimer = nil

  self.pool.onEntityAdded = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 1, self)
  end

  self.pool.onEntityRemoved = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 0, self)
  end
end

return GridCollisionSystem

local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'
local Timer = require 'libs.hump.timer'
local Polygon = require 'libs.HC.polygon'

local GridCollisionSystem = Concord.system({ pool = { "gridCollisionItem" } })

local debugRectangles = {}
local collisionPolygons = {}

local function setCollisionValue(x, y, value, self)
  local mapManager = Gamestate.current().mapManager
  mapManager:setCollisionMapValue(
  x,
  y,
  value)

  self:updateCollisionTileMap()
end

local function getEmptyCollisionTile()
  return {
    exists = false,
    edgeId = { n = nil, s = nil, w = nil, e = nil },
    polygonId = nil
  }
end

local getEmptyEdge = function()
  return {
    startPos = Vector(),
    endPos = Vector(),
    polygonId = nil
  }
end

local function createEmptyCollisionTileMap(width, height)
  return functional.generate(height, function(y)
    return functional.generate(width, function(x)
      return getEmptyCollisionTile()
    end)
  end)
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
      -- If no collision tile, do nothing
      --print("tile", tile)
      if tileValue == 1 then
        local tile = getSafe(tiles, x, y)
        print("tile", inspect(tile))
        if tile.tileExists then
          local leftTile = getSafe(tiles, x - 1, y)
          if leftTile and leftTile.tileExists and leftTile.rectangleId then
            tile.rectangleId = leftTile.rectangleId
            rectangles[tile.rectangleId].endX = x
            print("Merging now from to:", rectangles[tile.rectangleId].startX, rectangles[tile.rectangleId].endX) 
          else
            tile.rectangleId = getNewRectangleId()
            rectangles[tile.rectangleId] = {
              startX = x, endX = x, startY = y, endY = y, id = tile.rectangleId
            }
          end
        end
      end
    end
  end

  local mergedRectangles = table.copy(rectangles)

  -- Merge downwards when possible
  for _, rectangle in pairs(rectangles) do
    local rectanglesToBeMergedLeft = true

    while rectanglesToBeMergedLeft do
      -- Search mergedRectangles here because we don't want to find a rectangle we've already deemed to be merged
      local rectangleBelow = functional.find_match(mergedRectangles, function(otherRectangle)
        return otherRectangle.startY == rectangle.endY + 1 and
        otherRectangle.startX == rectangle.startX and otherRectangle.endX == rectangle.endX
      end)

      if rectangleBelow then
        -- Rectangle is identical in width so can merge
        rectangle.endY = rectangleBelow.endY
        table.remove_value(mergedRectangles, rectangleBelow)
      else
        rectanglesToBeMergedLeft = false
      end
    end
  end

  return mergedRectangles
end

local function createEdges(collisionMap, collisionTileMap, startX, startY, width, height, tileSize)
  local edges = {}

  -- First initialize collisionTileMap with collisionTile objects
  -- which will have "exists" based on whether there's a tile here or not
  for y=startY,startY+height-1 do
    for x=startX,startX+width-1 do
      collisionTileMap[y][x] = getEmptyCollisionTile()
      collisionTileMap[y][x].exists = collisionMap[y][x] == 1
    end
  end

  local currentPolygonIdIndex = 0

  local function getNewPolygonId()
    currentPolygonIdIndex = currentPolygonIdIndex + 1
    return currentPolygonIdIndex
  end

  for y=startY,startY+height-2 do
    local row = collisionTileMap[y]
    for x=startX,startX+width-2 do
      local current = collisionTileMap[y][x]
      local north = collisionTileMap[y-1] and collisionTileMap[y-1][x]
      local south = collisionTileMap[y+1] and collisionTileMap[y+1][x]
      local west = collisionTileMap[y][x-1]
      local east = collisionTileMap[y][x+1]

      if current.exists then
        -- If no west neighbor, it needs a western edge
        if not (west and west.exists) then
          -- If we already have an west edge in our north neighbor, extend that
          if north and north.edgeId.w then
            edges[north.edgeId.w].endPos.y = edges[north.edgeId.w].endPos.y + tileSize
            current.edgeId.w = north.edgeId.w
          else
            -- Else create new edge
            local edge = getEmptyEdge()
            edge.startPos.x = x * tileSize
            edge.startPos.y = y * tileSize
            edge.endPos.x = edge.startPos.x
            edge.endPos.y = edge.startPos.y + tileSize

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.w = edgeId
          end
        end

        -- If no east neighbor, it needs an eastern edge
        if not (east and east.exists) then
          -- If we already have an eastern edge in our north neighbor, extend that
          if north and north.edgeId.e then
            edges[north.edgeId.e].endPos.y = edges[north.edgeId.e].endPos.y + tileSize
            current.edgeId.e = north.edgeId.e
          else
            -- Else create new edge
            local edge = getEmptyEdge()
            edge.startPos.x = (x + 1) * tileSize
            edge.startPos.y = y * tileSize
            edge.endPos.x = edge.startPos.x
            edge.endPos.y = edge.startPos.y + tileSize

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.e = edgeId
          end
        end

        if not (north and north.exists) then
          if west and west.edgeId.n then
            edges[west.edgeId.n].endPos.x = edges[west.edgeId.n].endPos.x + tileSize
            current.edgeId.n = west.edgeId.n
          else
            local edge = getEmptyEdge()
            edge.startPos.x = x * tileSize
            edge.startPos.y = y * tileSize
            edge.endPos.x = edge.startPos.x + tileSize
            edge.endPos.y = edge.startPos.y

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.n = edgeId
          end
        end

        if not (south and south.exists) then
          if west and west.edgeId.s then
            edges[west.edgeId.s].endPos.x = edges[west.edgeId.s].endPos.x + tileSize
            current.edgeId.s = west.edgeId.s
          else
            local edge = getEmptyEdge()
            edge.startPos.x = x * tileSize
            edge.startPos.y = (y + 1) * tileSize
            edge.endPos.x = edge.startPos.x + tileSize
            edge.endPos.y = edge.startPos.y

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.s = edgeId
          end
        end

        -- if north and north.exists and north.polygonId then
        --   current.polygonId = north.polygonId
        -- elseif south and south.exists and south.polygonId then
        --   current.polygonId = south.polygonId
        -- elseif west and west.exists and west.polygonId then
        --   current.polygonId = west.polygonId
        -- elseif east and east.exists and east.polygonId then
        --   current.polygonId = east.polygonId
        -- else
        --   print("getNewPolygonId")
        --   current.polygonId = getNewPolygonId()
        --   print("polygonId now", current.polygonId)
        -- end

      end

      -- for _, dir in ipairs({'n', 's', 'w', 'e'}) do
      --   local edge = edges[current.edgeId[dir]]
      --   if edge then
      --     local polygonId = current.polygonId
      --     edge.polygonId = polygonId
      --     print("Set edge polygonId", inspect(edge.polygonId))
      --   end
      -- end
    end
  end

  return edges
end

local function createPolygon(startEdge, currentEdge, edgesRemaining, polygon)
  if not polygon then polygon = {} end

  if currentEdge and currentEdge.endPos == startEdge.endPos then
    print("Found start, returning polygon")
    return polygon
  end

  if not currentEdge then currentEdge = startEdge end

  print("Now trying to find match for our end position", currentEdge.endPos)
  local nextEdge = functional.find_match(edgesRemaining, function(otherEdge)
    return currentEdge.endPos == otherEdge.startPos
  end)

  -- if not nextEdge then return {} end
  if not nextEdge then error("Polygon did not have next edge") else
    print("Found nextEdge", nextEdge.startPos, nextEdge.endPos)
  end


  -- local remaining = functional.remove_if(edgesRemaining, function(otherEdge)
  --   return otherEdge == currentEdge
  -- end)
  local remaining = edgesRemaining

  table.insert(polygon, currentEdge)
  print("Inserting into polygon", currentEdge.startPos, currentEdge.endPos)
  return createPolygon(startEdge, nextEdge, remaining, polygon)
end

local createPolygons = function(edges)
  local polygons = {}
  local accountedForEdges = {}

  for _, edge in ipairs(edges) do
    if not functional.contains(accountedForEdges, edge) then
      local polygon = createPolygon(edge, nil, edges, {})
      for _, edge in ipairs(polygon) do
        table.insert(accountedForEdges, edge)
      end
      table.insert(polygons, polygon)
    end
  end

  return polygons
end

local bufferLength = 1.0
local bufferTimer = nil
function GridCollisionSystem:updateCollisionTileMap()
  if bufferTimer then return end
  bufferTimer = Timer.after(bufferLength, function()
    bufferTimer = nil
    local collisionMap = Gamestate.current().mapManager:getCollisionMap()
    print("collisionMap", inspect(collisionMap))
    local tileRectangles = mergeTilesIntoRectangles(collisionMap, Gamestate.current().mapManager.map.tileSize)
    print("tileRectangles", inspect(tileRectangles))
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
      entity:give("physicsBody", "polygon", { polygon = polygon }, { "wall" }, nil, true)
    end
  end)
end

-- WORKING CODE THAT CREATES POLYGONS, to be used later
-- function GridCollisionSystem:updateCollisionTileMap()
--   if bufferTimer then return end
-- 
--   print("Uhm")
--   bufferTimer = Timer.after(bufferLength, function()
--     local map = Gamestate.current().mapManager.map
--     local collisionMap = Gamestate.current().mapManager:getCollisionMap()
--     self.collisionTileMap = createEmptyCollisionTileMap(map.size.x, map.size.y)
-- 
--     print("Uh okay")
--     --local edgesWithMatches = functional.filter(edges, function(edge)
--     --  return functional.find_match(edges, function(otherEdge)
--     --    return edge.endPos == otherEdge.startPos or otherEdge.endPos == edge.startPos or edge.endPos == otherEdge.endPos
--     --  end)
--     --end)
--     --local polygons = createPolygons(edges)
--     --local polygons = functional.group_by(edges, function(edge) return edge.polygonId end)
--     --for _, collisionPolygon in ipairs(collisionPolygons) do
--     --  HC.remove(collisionPolygon)
--     --end
-- 
--     local edges = createEdges(collisionMap, self.collisionTileMap, 1, 1, map.size.x, map.size.x, map.tileSize)
--     local function sortPolygon(remainingEdges, startPos, currentPos, sorted, currentEdge)
--       local sorted = sorted or {}
--       local currentEdge = currentEdge or remainingEdges[1]
--       startPos = startPos or currentEdge.startPos
-- 
--       local currentPos = currentPos or currentEdge.startPos
--       table.insert(sorted, currentPos)
-- 
--       if not table.remove_value(remainingEdges, currentEdge) then error("currentEdge was not in remainingEdges") end
-- 
--       -- local nextEdge = functional.find_match(remainingEdges, function(otherEdge)
--       --   return currentEdge ~= otherEdge and (currentEdge.endPos == otherEdge.startPos or currentEdge.startPos == otherEdge.startPos)
--       -- end)
-- 
--       local nextEdge = functional.find_match(remainingEdges, function(otherEdge)
--         print("comparing", otherEdge.startPos, otherEdge.endPos, "to", currentPos)
--         return otherEdge.startPos == currentPos or otherEdge.endPos == currentPos
--       end)
--       print("nextEdge", nextEdge)
-- 
--       if not nextEdge then return sorted end
--       local nextPos = currentPos == nextEdge.endPos and nextEdge.startPos or nextEdge.endPos
-- 
--       print("currentPos, nextPos", currentPos, nextPos)
-- 
--       if not nextPos or nextPos == startPos then return sorted end
--       return sortPolygon(remainingEdges, startPos, nextPos, sorted, nextEdge)
--     end
-- 
--     local remaining = table.copy(edges)
--     local polygons = {}
-- 
--     while #remaining > 0 do
--       local polygon = sortPolygon(remaining)
--       table.insert(polygons, polygon)
--     end
-- 
--     local polygonId = 0
--     for i=1,#polygons,2 do
--       local polygon = polygons[i]
--       local nextPolygon = polygons[i+1]
--       print("polygon", inspect(polygon))
--       polygonId = polygonId + 1
--       local polygonTable = {}
--       for _, point in ipairs(polygon) do
--         --point.polygonId = polygonId
--         table.insert(polygonTable, point.x)
--         table.insert(polygonTable, point.y)
--       end
--       for _, point in ipairs(nextPolygon) do
--         --point.polygonId = polygonId
--         table.insert(polygonTable, point.x)
--         table.insert(polygonTable, point.y)
--       end
--       --for _, edge in ipairs(polygon) do
--       --  print("edge", inspect(edge))
--       --  edge.polygonId = polygonId
--       --  table.insert(polygonTable, startPos.x)
--       --  table.insert(polygonTable, startPos.y)
--       --  table.insert(polygonTable, endPos.x)
--       --  table.insert(polygonTable, endPos.y)
--       --end
-- 
--       print("polygonTable", unpack(polygonTable))
--       --local shape = HC.polygon(unpack(polygonTable))
--       local hcPolygon = Polygon(unpack(polygonTable))
--       local list
--       if not hcPolygon:isConvex() then
--         list = hcPolygon:splitConvex()
--       else
--         list = {hcPolygon:clone()}
--       end
--       
--       for _, convexPolygon in ipairs(list) do
--         local entity = Concord.entity(self:getWorld())
--         entity:give("physicsBody", "polygon", { polygon = {convexPolygon:unpack()} }, { "wall" }, nil, true)
--       end
--     end
-- 
--     -- for polygonId, polygon in pairs(polygons) do
--     --   print("polygon", inspect(polygon))
--     --   if #polygon > 2 then
--     --     local polygonTable = {}
--     --     local sorted = sortPolygon(table.values(polygon))
--     --     print("sorted", inspect(sorted))
--     --     for _, edge in ipairs(sorted) do
--     --       local startPos = edge.flipped and edge.endPos or edge.startPos
--     --       local endPos = edge.flipped and edge.startPos or edge.endPos
--     --       table.insert(polygonTable, startPos.x)
--     --       table.insert(polygonTable, startPos.y)
--     --       table.insert(polygonTable, endPos.x)
--     --       table.insert(polygonTable, endPos.y)
--     --     end
-- 
--     --     print("polygonTable", unpack(polygonTable))
--     --     --local shape = HC.polygon(unpack(polygonTable))
--     --     if #polygonTable > 8 then
--     --       local entity = Concord.entity(self:getWorld())
--     --       entity:give("physicsBody", "polygon", { polygon = polygonTable }, { "wall" }, nil, true)
--     --     end
--     --   end
--     -- end
--     --print("Okay", inspect(polygons))
--     debugEdges = edges
-- 
--     bufferTimer = nil
--   end)
-- end

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

function GridCollisionSystem:mapChange(map)
  self.collisionTileMap = createEmptyCollisionTileMap(map.size.x, map.size.y)
end

function GridCollisionSystem:init(_)
  self.collisionTileMap = createEmptyCollisionTileMap(10, 10)

  self.pool.onEntityAdded = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 1, self)
  end

  self.pool.onEntityRemoved = function(_, entity)
    setCollisionValue(entity.gridCollisionItem.x, entity.gridCollisionItem.y, 0, self)
  end
end

return GridCollisionSystem

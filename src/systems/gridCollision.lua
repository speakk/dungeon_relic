local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'
local Timer = require 'libs.hump.timer'

local GridCollisionSystem = Concord.system({ pool = { "gridCollisionItem" } })

local debugEdges = {}

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
    edgeExist = { n = false, s = false, w = false, e = false },
    edgeId = { n = nil, s = nil, w = nil, e = nil }
  }
end

local getEmptyEdge = function()
  return {
    startPos = Vector(),
    endPos = Vector()
  }
end

local function createEmptyCollisionTileMap(width, height)
  return functional.generate(height, function(y)
    return functional.generate(width, function(x)
      return getEmptyCollisionTile()
    end)
  end)
end

local function createEdges(collisionMap, collisionTileMap, startX, startY, width, height, tileSize)
  local edges = {}
  print("collisionTileMap", #collisionTileMap)

  -- First initialize collisionTileMap with collisionTile objects
  -- which will have "exists" based on whether there's a tile here or not
  for y=startY,startY+height-1 do
    for x=startX,startX+width-1 do
      print("Getting collisionMap value", x, y, collisionMap[y][x])
      collisionTileMap[y][x] = getEmptyCollisionTile()
      collisionTileMap[y][x].exists = collisionMap[y][x] == 1
    end
  end

  for y=startY+1,startY+height-2 do
    local row = collisionTileMap[y]
    for x=startX+1,startX+width-2 do
      local current = collisionTileMap[y][x]
      local north = collisionTileMap[y-1][x]
      local south = collisionTileMap[y+1][x]
      local west = collisionTileMap[y][x-1]
      local east = collisionTileMap[y][x+1]

      if current.exists then
        -- If no west neighbor, it needs a western edge
        if not west.exists then
          -- If we already have an west edge in our north neighbor, extend that
          if north.edgeExist.w then
            edges[north.edgeId.w].endPos.y = edges[north.edgeId.w].endPos.y + tileSize
            current.edgeId.w = north.edgeId.w
            current.edgeExist.w = true
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
            current.edgeExist.w = true
          end
        end

        if not east.exists then
          if north.edgeExist.e then
            edges[north.edgeId.e].endPos.y = edges[north.edgeId.e].endPos.y + tileSize
            current.edgeId.e = north.edgeId.e
            current.edgeExist.e = true
          else
            local edge = getEmptyEdge()
            edge.startPos.x = (x + 1) * tileSize
            edge.startPos.y = y * tileSize
            edge.endPos.x = edge.startPos.x
            edge.endPos.y = edge.startPos.y + tileSize

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.e = edgeId
            current.edgeExist.e = true
          end
        end

        if not north.exists then
          if west.edgeExist.n then
            edges[west.edgeId.n].endPos.x = edges[west.edgeId.n].endPos.x + tileSize
            current.edgeId.n = west.edgeId.n
            current.edgeExist.n = true
          else
            local edge = getEmptyEdge()
            edge.startPos.x = x * tileSize
            edge.startPos.y = y * tileSize
            edge.endPos.x = edge.startPos.x + tileSize
            edge.endPos.y = edge.startPos.y

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.n = edgeId
            current.edgeExist.n = true
          end
        end

        if not south.exists then
          if west.edgeExist.s then
            print("Had edge?", west.edgeId.s)
            edges[west.edgeId.s].endPos.x = edges[west.edgeId.s].endPos.x + tileSize
            current.edgeId.s = west.edgeId.s
            current.edgeExist.s = true
          else
            local edge = getEmptyEdge()
            edge.startPos.x = x * tileSize
            edge.startPos.y = (y + 1) * tileSize
            edge.endPos.x = edge.startPos.x + tileSize
            edge.endPos.y = edge.startPos.y

            local edgeId = #edges + 1
            table.insert(edges, edge)

            current.edgeId.s = edgeId
            current.edgeExist.s = true
          end
        end
      end
    end
  end

  return edges
end

local bufferLength = 1.0
local bufferTimer = nil
function GridCollisionSystem:updateCollisionTileMap()
  if bufferTimer then return end

  print("Uhm")
  bufferTimer = Timer.after(bufferLength, function()
    local map = Gamestate.current().mapManager.map
    local collisionMap = Gamestate.current().mapManager:getCollisionMap()
    self.collisionTileMap = createEmptyCollisionTileMap(map.size.x, map.size.y)

    print("Uh okay")
    local edges = createEdges(collisionMap, self.collisionTileMap, 1, 1, map.size.x, map.size.x, map.tileSize)
    print("Okay", inspect(edges))
    debugEdges = edges

    bufferTimer = nil
  end)
end

function GridCollisionSystem:drawDebugWithCamera()
  for _, edge in ipairs(debugEdges) do
    love.graphics.line(edge.startPos.x, edge.startPos.y, edge.endPos.x, edge.endPos.y)
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

local bitser = require 'libs.bitser'
local settings = require 'settings'
local positionUtil = require 'utils.position'
local dungeonGenerator = require 'utils.dungeonGenerator'

local function isPositionAvailable(self, x, y)
  return self.collisionMap[positionUtil.positionToString(x, y)]
end

local tilesetImageFloor = love.graphics.newImage('media/tileset/floor_bricks.png')
local tilesetImageWall = love.graphics.newImage('media/tileset/wall_bumpy.png')
local tilesetVoid = love.graphics.newImage('media/tileset/void.png')
local tilesetRoomFloor = love.graphics.newImage('media/tileset/room_floor.png')

local bitmaskIndices = {
  0, 4, 84, 92, 124, 116, 80,
  16, 28, 117, 95, 255, 253, 113,
  21, 87, 221, 127, 255, 247, 209,
  29, 125, 119, 199, 215, 213, 81,
  31, 255, 241, 20, 65, 17, 1,
  23, 223, 245, 85, 68, 93, 112,
  5, 71, 197, 69, 64, 7, 193
}

local bitmaskToTilesetIndex = {}
for i=1, #bitmaskIndices do
  bitmaskToTilesetIndex[bitmaskIndices[i]] = i
end

local tilesetTileSize = 32
local tilesetW = 7
local tilesetH = 7

local tilesetQuads = {}
for y=0,tilesetH-1 do
  for x=0,tilesetW-1 do
    local quad = love.graphics.newQuad(x*tilesetTileSize, y*tilesetTileSize,
      tilesetTileSize, tilesetTileSize,
      tilesetW*tilesetTileSize, tilesetH*tilesetTileSize)
    table.insert(tilesetQuads, quad)
  end
end

local bitmaskValues = {
  n = 1, ne = 2, e = 4,
  se = 8, s = 16,
  sw = 32, w = 64, nw = 128
}

local function getMapValueSafe(map, x, y)
  if not map[y] or not map[y][x] then return nil end
  return map[y][x]
end

local function calculateAutotileBitmask(x, y, map, tileValue)
  local allDirections = {
    n = { x = x, y = y - 1 },
    nw = { x = x-1, y = y-1, neighbors = { "n", "w" } },
    ne = { x = x+1, y = y-1, neighbors = { "n", "e" } },
    w = { x = x-1, y = y },
    e = { x = x+1, y = y },
    s = { x = x, y = y+1 },
    sw = { x = x-1, y = y+1, neighbors = { "s", "w" } },
    se = { x = x+1, y = y+1, neighbors = { "s", "e" } }
  }

  local isBlocked = function(mapValue)
    return mapValue ~= tileValue
  end

  local value = 0
  for dir, coords in pairs(allDirections) do
    if not isBlocked(getMapValueSafe(map, coords.x, coords.y)) then
      if coords.neighbors then
        local hasBothNeighbors = true
        for _, neighborDir in pairs(coords.neighbors) do
          local neighbor = allDirections[neighborDir]
          if isBlocked(getMapValueSafe(map, neighbor.x, neighbor.y)) then
            hasBothNeighbors = false
          end
        end

        if hasBothNeighbors then
          value = value + bitmaskValues[dir]
        end
      else
        value = value + bitmaskValues[dir]
      end
    end
  end

  return value
end

local tileValueToTileset = {
  wall = tilesetImageWall,
  roomFloor = tilesetImageFloor,
  floor = tilesetRoomFloor,
  void = tilesetVoid
}

local function drawAutotile(x, y, tileValue, tileSize, _, tiles, offsetX, offsetY)
  local finalX = (x - offsetX) * tileSize
  local finalY = (y - offsetY) * tileSize

  local tileSet = tileValueToTileset[tileValue]

  local autotileBitmask = calculateAutotileBitmask(x, y, tiles, tileValue)

  local index = bitmaskToTilesetIndex[autotileBitmask]
  if tilesetQuads[index] then
    love.graphics.draw(tileSet, tilesetQuads[index], finalX, finalY)
  end
end

-- Draw a random tile from the tileset associated with the tileValue
local function drawTile(x, y, tileValue, tileSize, _, _, offsetX, offsetY)
  local finalX = (x - offsetX) * tileSize
  local finalY = (y - offsetY) * tileSize

  local tileSet = tileValueToTileset[tileValue]

  local w,h = tileSet:getDimensions()
  local quadX = love.math.random(0, (w/tileSize)-1)
  local quadY = love.math.random(0, (h/tileSize)-1)


  -- TODO: Pre-create these quads, this is super wasteful
  local quad = love.graphics.newQuad(quadX*tileSize, quadY*tileSize,
    tileSize, tileSize, w, h)

  love.graphics.draw(tileSet, quad, finalX, finalY)
end

local function placeEntity(assemblageId, gridX, gridY, world)
  local entity = Concord.entity(world):assemble(ECS.a.getBySelector(assemblageId))
  entity:give("position", gridX*settings.tileSize + settings.tileSize/2, gridY*settings.tileSize + settings.tileSize/2)
  return entity
end

local function spawnPlayer(x, y, world)
  placeEntity("items.leather_armor", x+1, y+1, world)
  placeEntity("items.leather_armor", x+1, y+2, world)
  local player = placeEntity("characters.player", x, y, world)
  local inventoryEntity = Concord.entity(world):assemble(ECS.a.getBySelector('items.backbag'))
  print("ID?", player.id.value, inventoryEntity.id.value)
  player:give("inventory", inventoryEntity.id.value)
end

local function createCollisionEntity(x, y, _, _, world) Concord.entity(world):give("gridCollisionItem", x, y):setSerializable(false) end

local handleTile = {
  wall = {drawAutotile, createCollisionEntity},
  floor = {drawTile},
  roomFloor = {drawTile},
  void = {drawTile, createCollisionEntity},
}

local getRandomPositionInRoom = function(dungeon, room, padding)
  if padding > room.w/2 or padding > room.h/2 then error("Padding too large for room size") end
  local empties = {}
  for y=room.y+padding,room.y+room.h-padding do
    for x=room.x+padding,room.x+room.w-padding do
      if dungeon[y][x] == "floor" then table.insert(empties, {x,y}) end
    end
  end

  if #empties == 0 then error("No empty spot found in room") end

  local empty = table.pick_random(empties)
  local x, y = empty[1],empty[2]

  if dungeon[y][x] == "wall" then
    error ("Trying to get position in room which is actually wall x/y: " .. x .. "/" .. y)
  end

  return x, y
end

local getPositionInRandomRoom = function(dungeon, rooms, padding)
  local nonNilRooms = functional.filter(rooms, function(room) return room end)
  padding = padding or 1
  local randomRoom = table.pick_random(nonNilRooms)
  local x, y = getRandomPositionInRoom(dungeon, randomRoom, padding)
  return x, y, randomRoom
end


-- Run only when initializing new game
local function spawnEntities(dungeon, descending, world, firstGameStart)
  if #(dungeon.rooms) == 0 then error("No rooms in dungeon") end

  -- ENTRANCE / EXIT START
  -- Create exit
  local exitX, exitY, exitRoom = getPositionInRandomRoom(dungeon.tiles, dungeon.rooms, 2)
  placeEntity("dungeon_features.portal_down", exitX, exitY, world)

  -- Create entrance room. Make sure we find one that is not the same as the exit room
  local nonExitRooms = functional.filter(table.copy(dungeon.rooms), function(room)
    return room ~= exitRoom
  end)
  if #nonExitRooms == 0 then error("No nonExitRooms found") end
  local entranceX, entranceY, entranceRoom = getPositionInRandomRoom(dungeon.tiles, nonExitRooms, 2)
  if not entranceRoom then error("No eligible entrance room found, exiting") end

  placeEntity("dungeon_features.portal_up", entranceX, entranceY, world)

  if firstGameStart then
    if descending then
      spawnPlayer(entranceX+1, entranceY+1, world)
    else
      spawnPlayer(exitX+1, exitY+1, world)
    end
  end
  -- ENTRANCE / EXIT END

  for _=1,10 do
    local x, y, _ = getPositionInRandomRoom(dungeon.tiles, dungeon.rooms, 1)
    placeEntity("dungeon_features.pillar", x, y, world)
  end

  for _=1,10 do
    local x, y, _ = getPositionInRandomRoom(dungeon.tiles, dungeon.rooms, 1)
    placeEntity("dungeon_features.bush", x, y, world)
  end

  for _=1,20 do
    local x, y, _ = getPositionInRandomRoom(dungeon.tiles, dungeon.rooms, 1)
    if love.math.random() > 0.5 then
      placeEntity("characters.flopper", x, y, world)
    else
      placeEntity("characters.monsterA", x, y, world)
    end
  end
end

local function drawCanvas(tileSize, mapData, world, canvasSizeX, canvasSizeY, startX, startY, endX, endY)
  local canvas = love.graphics.newCanvas(canvasSizeX, canvasSizeY)
  love.graphics.setCanvas(canvas)

  for y = startY, endY -1 do
    for x = startX, endX -1 do
      if mapData[y] and mapData[y][x] then
        local tileValue = mapData[y][x]
        local tileHandlers = handleTile[tileValue]
        if tileHandlers then
          for _, tileHandler in ipairs(tileHandlers) do
            tileHandler(x, y, tileValue, tileSize, world, mapData, startX, startY)
          end
        else
          error ("No tile handler for: " .. tileValue)
        end
      end
    end

  end

  love.graphics.setCanvas()
  return canvas
end

local function initializeMap(map, world)
  local canvasSizeInTilesX = 10
  local canvasSizeInTilesY = 10

  local canvasesX = math.ceil(map.width/canvasSizeInTilesX)
  local canvasesY = math.ceil(map.height/canvasSizeInTilesY)

  for canvasY=0,canvasesY-1 do
    for canvasX=0,canvasesX-1 do
      local startX = canvasX * canvasSizeInTilesX + 1
      local startY = canvasY * canvasSizeInTilesY + 1
      local endX = startX + canvasSizeInTilesX
      local endY = startY + canvasSizeInTilesY
      local canvasWidth = canvasSizeInTilesX * settings.tileSize
      local canvasHeight = canvasSizeInTilesY * settings.tileSize

      local canvas = drawCanvas(
      settings.tileSize,
      map.mapData.tiles,
      world,
      canvasWidth, canvasHeight,
      startX, startY, endX, endY
      )

      local atlas = mediaManager:getAtlas("dynamic")
      local mediaEntity = atlas:addImage(canvas:newImageData())

      local mediaPath = 'mapLayerCache.floor' .. startX .. "|" .. startY
      mediaManager:setMediaEntity(mediaPath, mediaEntity)

      Concord.entity(world)
      :give('sprite', mediaPath, "ground")
      :give('size', canvasWidth, canvasHeight)
      :give('position', startX * settings.tileSize, startY * settings.tileSize)
      :setSerializable(false)
    end
  end
end

local MapManager = Class {
  init = function(self, map, world)
    self.collisionMap = functional.generate(map.height, function(_)
      return functional.generate(map.width, function(_)
        return 0
      end)
    end)

    self.map = map
    initializeMap(map, world)
  end,

  initializeEntities = function(self, descending, world, firstGameStart)
    spawnEntities(self.map.mapData, descending, world, firstGameStart)
  end,

  -- Note: x and y are grid coordinates, not pixel
  -- value: 0 = no collision 1 = collision
  setCollisionMapValue = function(self, x, y, value)
    self.collisionMap[y][x] = value
  end,

  getCollisionMap = function(self)
    return self.collisionMap
  end,

  getMap = function(self)
    return self.map
  end,

}

MapManager.generateMap = function()
  local outerPadding = 1

  local width=30
  local height=30

  local dungeon = dungeonGenerator.generateDungeon(width, height, 10, 10, {
    roomsMin = 8,
    roomsMax = 9,
    roomWidthMin = 4,
    roomHeightMin = 5,
    outerPadding = outerPadding
  })

  local map = {
    mapData = dungeon,
    width = width + outerPadding*2,
    height = height + outerPadding*2
  }

  return map
end

return MapManager

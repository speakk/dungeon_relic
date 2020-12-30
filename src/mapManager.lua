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
  floor = tilesetImageFloor,
  roomFloor = tilesetRoomFloor,
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

local function placeEntity(assemblageId, tileSize, gridX, gridY, world)
  local entity = Concord.entity(world):assemble(ECS.a.getBySelector(assemblageId))
  entity:give("position", gridX*tileSize, gridY*tileSize)
end

local tileValueToEntity = {
  void = function(x, y, _, _, world)
    return Concord.entity(world):give("gridCollisionItem", x, y)
  end,
  exit = function(x, y, _, tileSize, world) placeEntity("dungeon_features.portal_down", tileSize, x, y, world) end,
  entrance = function(x, y, _, tileSize, world) placeEntity("dungeon_features.portal_up", tileSize, x, y, world) end,
  spawner = function(x, y, _, tileSize, world) placeEntity("dungeon_features.spawner", tileSize, x, y, world) end,
  monster = function(x, y, _, tileSize, world) placeEntity("characters.monsterA", tileSize, x, y, world) end,
  pillar = function(x, y, _, tileSize, world) placeEntity("dungeon_features.pillar", tileSize, x, y, world) end,
  bush = function(x, y, _, tileSize, world) placeEntity("dungeon_features.bush", tileSize, x, y, world) end,
  player = function(x, y, _, tileSize, world) placeEntity("characters.player", tileSize, x, y, world) end,
  wall = function(x, y, _, _, world) return Concord.entity(world):give("gridCollisionItem", x, y) end
}

local function createEntity(x, y, tileValue, tileSize, world, tiles)
  tileValueToEntity[tileValue](x, y, tileValue, tileSize, world, tiles)
end

local handleTile = {
  wall = {drawAutotile, createEntity},
  floor = {drawTile},
  roomFloor = {drawTile},
  void = {drawTile, createEntity},
  exit = {createEntity},
  entrance = {createEntity},
  spawner = {createEntity},
  monster = {createEntity},
  pillar = {createEntity},
  bush = {createEntity},
  player = {createEntity}
}

local function drawCanvas(tileSize, layers, world, canvasSizeX, canvasSizeY, startX, startY, endX, endY)
  print("Drawing map canvas, size: ", canvasSizeX, canvasSizeY, "start x, y", startX, startY, "end x, y", endX, endY)
  local canvas = love.graphics.newCanvas(canvasSizeX, canvasSizeY)
  love.graphics.setCanvas(canvas)

  -- NOTE: Right now drawing all layers right on each other in the same canvas.
  -- Consider possible benefits of having the layers being drawn separately
  -- (would allow parallax movement between layers etc)
  for _, layer in ipairs(layers) do
    local tiles = layer.tiles
    for y = startY, endY -1 do
      for x = startX, endX -1 do
        if tiles[y] and tiles[y][x] then
          local tileValue = tiles[y][x]
          local tileHandlers = handleTile[tileValue]
          if tileHandlers then
            for _, tileHandler in ipairs(tileHandlers) do
              tileHandler(x, y, tileValue, tileSize, world, tiles, startX, startY)
            end
          else
            error ("No tile handler for: " .. tileValue)
          end
        end
      end
    end

  end

  love.graphics.setCanvas()
  return canvas
end

local function drawMap(map, world)
  local canvasSizeInTilesX = 10
  local canvasSizeInTilesY = 10

  local canvasesX = math.ceil(map.size.x/canvasSizeInTilesX)
  local canvasesY = math.ceil(map.size.y/canvasSizeInTilesY)

  local entities = {}

  for canvasY=0,canvasesY-1 do
    for canvasX=0,canvasesX-1 do
      local startX = canvasX * canvasSizeInTilesX + 1
      local startY = canvasY * canvasSizeInTilesY + 1
      local endX = startX + canvasSizeInTilesX
      local endY = startY + canvasSizeInTilesY
      local canvasWidth = canvasSizeInTilesX * map.tileSize
      local canvasHeight = canvasSizeInTilesY * map.tileSize

      local canvas = drawCanvas(
      map.tileSize,
      map.layers,
      world,
      canvasWidth, canvasHeight,
      startX, startY, endX, endY
      )

      local atlas = mediaManager:getAtlas("dynamic")
      local mediaEntity = atlas:addImage(canvas:newImageData())

      local mediaPath = 'mapLayerCache.floor' .. startX .. "|" .. startY
      mediaManager:setMediaEntity(mediaPath, mediaEntity)

      local entity = Concord.entity()
      :give('sprite', mediaPath, "ground")
      :give('size', canvasWidth, canvasHeight)
      :give('position', startX * map.tileSize, startY * map.tileSize)

      table.insert(entities, entity)
    end
  end

  return entities
end

local function clearMediaEntries(entities)
  if not entities then return end
  for _, entity in ipairs(entities) do
    mediaManager:removeMediaEntity(entity.sprite.image)
  end
end

local function clearEntities(entities)
  if not entities then return end
  for _, entity in ipairs(entities) do
    entity:destroy()
  end

  entities.length = 0
end


local MapManager = Class {
  init = function(self)
    self.collisionMap = {}
    self.map = {}
    self.entities = {}
    self.layerSprites = {}
  end,

  -- Note: x and y are grid coordinates, not pixel
  -- value: 0 = no collision 1 = collision
  setCollisionMapValue = function(self, x, y, value)
    self.collisionMap[y][x] = value
  end,

  getCollisionMap = function(self)
    return self.collisionMap
  end,

  setMap = function(self, map, world)
    print("setMap, new map ahoy!", map)
    clearMediaEntries(self.floorCanvasEntities)
    clearEntities(self.floorCanvasEntities)

    self.collisionMap = functional.generate(map.size.y, function(_)
      return functional.generate(map.size.x, function(_)
        return 0
      end)
    end)

    self.map = map

    self.mapCanvasEntities = drawMap(map, world)

    for _, entity in ipairs(self.mapCanvasEntities) do
      world:addEntity(entity)
    end
  end,

  getMap = function(self)
    return self.map
  end,

  getPath = function(self, fromX, fromY, toX, toY)
    return luastar:find(self.map.size.x, self.map.size.y,
      { x = fromX, y = fromY },
      { x = toX, y = toY },
      isPositionAvailable,
      true)
  end
}

local function createLayer(width, height, valueFunction)
  local layer = {
    tiles = {}
  }
  if width and height then
    for y=1,height do
      local row = {}
      table.insert(layer.tiles, row)

      for x=1,width do
        if valueFunction then
          row[x] = valueFunction(x, y)
        end
      end
    end
  end

  return layer
end

local function generateSimpleMap(seed, descending, width, height)
  width = width
  height = height
  local map = { layers = {} }
  --local scale = 0.1
  --
  -- roomWidth table Room width for rectangle one of cross rooms (default {4)
  -- roomHeight table Room height for rectangle one of cross rooms (default {3)
  -- crossWidth table Room width for rectangle two of cross rooms (default {3)
  -- crossHeight table Room height for rectangle two of cross rooms (default {2)
  -- corridorWidth table Length of east-west corridors (default {3)
  -- corridorHeight table Length of north-south corridors (default {2)

  -- local rotMapGenerator = ROT.Map.Brogue:new(width, height,{
  -- })

  local dungeon = dungeonGenerator.generateDungeon(width, height, 10, 10, {
    roomWidthMin = 5,
    roomHeightMin = 5
  })

  local rotMapLayer = {}

  for y=1,#dungeon.tiles[1] do
    local row = dungeon.tiles[y]
    if not rotMapLayer[y] then rotMapLayer[y] = {} end
    for x=1,#row do
      local tile = dungeon.tiles[y][x]
      if tile == "floor" then print("Floor at x/y", x,y) end
      rotMapLayer[y][x] = tile -- TODO: Add type mapping here
    end
  end


  -- local rotMap = rotMapGenerator:create(function(x, y, type)
  --   if not rotMapLayer[y] then rotMapLayer[y] = {} end
  --   if type == 0 then rotMapLayer[y][x] = "floor" end
  --   if type == 1 then rotMapLayer[y][x] = "wall" end
  --   if type == 2 then rotMapLayer[y][x] = "floor" end -- TODO: add door
  -- end, false)

  local getRandomPositionInRoom = function(room, padding)
    if padding > room.w/2 or padding > room.h/2 then error("Padding too large for room size") end
    local empties = {}
    print("ROOM", inspect(room))
    for y=room.y+padding,room.y+room.h-padding do
      for x=room.x+padding,room.x+room.w-padding do
        print(rotMapLayer[y][x])
        if rotMapLayer[y][x] == "floor" then table.insert(empties, {x,y}) end
      end
    end

    if #empties == 0 then error("No empty spot found in room") end

    local empty = table.pick_random(empties)
    local x, y = empty[1],empty[2]

    print("Final x, y", x, y)
    if rotMapLayer[y][x] == "wall" then
      error ("Trying to get position in room which is actually wall x/y: " .. x .. "/" .. y)
    end

    return x, y
  end

  local getPositionInRandomRoom = function(rooms, padding)
    local nonNilRooms = functional.filter(rooms, function(room) return room end)
    padding = padding or 1
    local randomRoom = table.pick_random(nonNilRooms)
    local x, y = getRandomPositionInRoom(randomRoom, padding)
    return x, y, randomRoom
  end

  local featuresLayer = createLayer(width, height)

  if #(dungeon.rooms) == 0 then error("No rooms in dungeon") end

  --for _=1,5 do
  --  local spawnerX, spawnerY = getPositionInRandomRoom(rotMap._rooms)
  --  featuresLayer.tiles[spawnerY][spawnerX] = "spawner"
  --end

  -- ENTRANCE / EXIT START
  -- Create exit
  local exitX, exitY, exitRoom = getPositionInRandomRoom(dungeon.rooms, 2)
  featuresLayer.tiles[exitY][exitX] = "exit"

  -- Create entrance room. Make sure we find one that is not the same as the exit room
  local nonExitRooms = functional.filter(table.copy(dungeon.rooms), function(room)
    return room ~= exitRoom
  end)
  if #nonExitRooms == 0 then error("No nonExitRooms found") end
  local entranceX, entranceY, entranceRoom = getPositionInRandomRoom(nonExitRooms, 2)
  if not entranceRoom then error("No eligible entrance room found, exiting") end

  featuresLayer.tiles[entranceY][entranceX] = "entrance"
  if descending then
    featuresLayer.tiles[entranceY+1][entranceX] = "player"
  else
    featuresLayer.tiles[exitY+1][exitX] = "player"
  end
  -- ENTRANCE / EXIT END

  for _=1,10 do
    local x, y, _ = getPositionInRandomRoom(dungeon.rooms, 1)
    if not featuresLayer.tiles[y][x] then
      featuresLayer.tiles[y][x] = "pillar"
    end
  end

  for _=1,10 do
    local x, y, _ = getPositionInRandomRoom(dungeon.rooms, 1)
    if not featuresLayer.tiles[y][x] then
      featuresLayer.tiles[y][x] = "bush"
    end
  end

  for _=1,20 do
    local x, y, _ = getPositionInRandomRoom(dungeon.rooms, 1)
    if not featuresLayer.tiles[y][x] then
      featuresLayer.tiles[y][x] = "monster"
    end
  end

  table.insert(map.layers, featuresLayer)

  -- Fill the whole thing up with floor
  table.insert(map.layers, createLayer(width, height, function(x, y)
    for _, room in ipairs(dungeon.rooms) do
      local l,t,r,b = room.x,room.y,room.x+room.w,room.y+room.h
      if x >= l and x <= r and y >= t and y <= b then
        return 'roomFloor'
      end
    end
    return 'floor'
  end))

  table.insert(map.layers, createLayer(width, height, function(x, y)
    local value = rotMapLayer[y][x]
    if value == "wall" then return value end
  end))
  return map
end

MapManager.generateMap = function(levelNumber, descending)
  local tileSize = 32

  local width = 30
  local height = 30

  local map = generateSimpleMap(levelNumber, descending, width, height)

  return {
    tileSize = tileSize,
    size = { x = width, y = height },
    layers = map.layers
  }
end

return MapManager

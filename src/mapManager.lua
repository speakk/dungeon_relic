local astray = require 'libs.astray'

local positionUtil = require 'utils.position'

local function isPositionAvailable(self, x, y)
  return self.collisionMap[positionUtil.positionToString(x, y)]
end

local tileValueToMediaId = {
  empty = 'tiles.ground_1',
  wall = 'tiles.wall_1' 
}

local function drawTile(x, y, tileValue, tileSize, world)
  local mediaId = tileValueToMediaId[tileValue]
  local mediaEntity = mediaManager:getMediaEntity(mediaId)
  local finalX = (x) * tileSize -- TODO -3, really?
  local finalY = (y) * tileSize
  love.graphics.draw(mediaEntity.atlas, mediaEntity.quad, finalX, finalY)
end

local tileValueToEntity = {
  wall = function(x, y, tileValue, tileSize, world)
    --print("tileValue", tileValue)
    --print("Creating wall entity", x*tileSize, y*tileSize, tileValueToMediaId[tileValue], world)
    local entity = Concord.entity(world)
      :give("position", x * tileSize, y * tileSize)
      :give("sprite", tileValueToMediaId[tileValue])
      :give("gridCollisionItem", x, y)
      --:give('physicsBody', 70, { 'wall' }, { 'wall' }, true)

    return entity
  end
}

local function createEntity(x, y, tileValue, tileSize, world)
  tileValueToEntity[tileValue](x, y, tileValue, tileSize, world)
end

local handleTile = {
  empty = drawTile,
  wall = createEntity
}

local function drawCanvas(map, tiles, world, canvasSizeX, canvasSizeY)
  local tileSize = map.tileSize
  local canvas = love.graphics.newCanvas(canvasSizeX, canvasSizeY)
  print("size of canvas", canvasSizeX, canvasSizeY)
  love.graphics.setCanvas(canvas)

  for y = 1, #tiles[1] do
    local line = ''
    for x = 1, #tiles do
      local tileValue = tiles[y][x]
      local tileHandler = handleTile[tileValue]
      if tileHandler then
        tileHandler(x, y, tileValue, tileSize, world)
      end
      --line = line .. tiles[y][x]
    end
    --print(line)
  end


  -- for _, tile in ipairs(tiles) do
  --   local mediaEntity = mediaManager:getMediaEntity(tile.spriteId)
  --   --print("spriteId", tile.spriteId, inspect(mediaEntity))
  --   local finalX = tile.x * tileSize
  --   local finalY = tile.y * tileSize
  --   love.graphics.draw(mediaEntity.atlas, mediaEntity.quad, finalX, finalY)
  -- end

  love.graphics.setCanvas()
  return canvas
end

local function drawFloor(map, world)
  local tileSize = map.tileSize

  -- TODO: Split canvas into multiple chunks
  local canvas = drawCanvas(
    map,
    map.tiles,
    world,
    positionUtil.gridToPixels(map.size.x, map.size.y)
  )

  local w, h = canvas:getDimensions()
  local quad = love.graphics.newQuad(0, 0, w, h, w, h)
  local mediaEntity = {
    atlas = canvas,
    quad = quad,
    metaData = {},
    origin = { x = 0, y = 0 }
  }

  local mediaPath = 'mapLayerCache.floor'
  mediaManager:setMediaEntity(mediaPath, mediaEntity)
  local entity = Concord.entity()
  :give('sprite', mediaPath)
  :give('size', w, h)
  :give('position', 0, 0)

  return entity
end

local function clearMediaEntries(mediaEntries)
  for _, mediaEntry in ipairs(mediaEntries) do
    mediaManager:removeMediaEntity('mapCache.' .. mediaEntry.name)
  end
end

local function initializeMapEntities(map)
  local entities = {}
  if not map.entities then return end
  for _, entityData in ipairs(map.entities) do
    local entity = Concord.entity()
    if entityData.assemblageSelector then
      entity:assemble(ECS.a.getBySelector(entityData.assemblageSelector))
    elseif entityData.components then
      for _, component in ipairs(entityData.components) do
        if component.properties then
          entity:give(component.name, unpack(component.properties))
        else
          entity:give(component.name)
        end
      end
    else
      error("Map entity had no component data")
    end

    table.insert(entities, entity)
  end

  return entities
end

local function clearEntities(entities)
  for _, entity in ipairs(entities) do
    entity:destroy()
  end

  entities.length = 0
end

-- -- Generate two dimensional table populated by:
-- -- - empty {} objects if no tileGenerateFunction present
-- -- - otherwise return the result of tileGenerateFunction(x, y)
-- local function generatePrefilledMap(width, height, tileGenerateFunction)
--   return functional.generate(height, function(y)
--     return functional.generate(width, function(x)
--       if tileGenerateFunction then
--         return tileGenerateFunction(x, y)
--       else
--         return {} -- empty tile object
--       end
--     end)
--   end)
-- end
-- 
-- -- NOTE: Modifies "map".
-- -- Then returns rooms table
-- local function generateRooms(map, width, height)
--   local roomAmount = 5
--   local rooms = functional.generate(roomAmount, function(i)
--     return {
--       dimensions = { x = love.math.random(10), y = love.math.random(10) }
--       position = { x = love.math.random(width), y = love.math.random(height) }
--     }
--   end)
-- 
--   for _, room in ipairs(rooms) do
--     for y=1,room.dimensions.y do
--       for x=1,room.dimensions.x do
--         local pos = { x = room.position.x + x, y = room.position.y + y }
--         local tileType = "room_floor"
-- 
--         if y == 1 or y == room.dimensions.y
--           or x == 1 or x == room.dimensions.x then
--           tileType = "room_wall"
--         end
-- 
--         map[pos.y][pos.x].tileType = tileType
--       end
--     end
--   end
-- 
--   return rooms
-- end
-- 
-- local function generateCorridors(map, rooms, width, height)
--   for _, room in ipairs(rooms) do
--     local startPosition = {
--       x = love.math.random(room.position.x, room.position.x + room.dimensions.x),
--       y = love.math.random(room.position.y, room.position.y + room.dimensions.y)
--     }
--     local vertical = love.math.random() > 0.5
--     if vertical then
--       endPosition
--     -- local endPosition = {
--     --   x = love.math.random(room.position.x, room.position.x + room.dimensions.x),
--     --   y = love.math.random(room.position.y, room.position.y + room.dimensions.y)
--     -- }
--   end
-- end
-- 
-- local function generateMap(width, height)
--   function tileGenerateFunction = function(x, y) return { tileType = "wall" }
--   local map = generateEmptyMap(width, height, tileGenerateFunction)
--   local rooms = generateRooms(map)
--   generateCorridors(map)
-- end

local function initializeEntities(world, entities)
  for _, entity in ipairs(entities) do
    world:addEntity(entity)
  end
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
    --self.collisionMap[positionUtil.positionToString(x, y)] = value
    print("setCollisionMapValue", x, y, value)
    self.collisionMap[y][x] = value
  end,

  getCollisionMap = function(self)
    return self.collisionMap
  end,

  setMap = function(self, map, world)
    --print("Setting map", inspect(map))
    
    -- clearEntities(self.entities)
    -- clearEntities(self.layerSprites)
    -- clearMediaEntries(self.mediaEntries)

    self.collisionMap = functional.generate(map.size.y, function(y)
      return functional.generate(map.size.x, function(x)
        return 0
      end)
    end)
    self.map = map
    self.floorEntity = drawFloor(map, world)
    world:addEntity(self.floorEntity)
    --self.entities = initializeMapEntities(map)


    -- initializeEntities(world, self.layerSprites)
    -- initializeEntities(world, self.entities)
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

MapManager.generateMap = function()
  local tileSize = 64

  -- Astray:new(width/2-1, height/2-1, changeDirectionModifier (1-30), sparsenessModifier (25-70), deadEndRemovalModifier (70-99) ) | RoomGenerator:new(rooms, minWidth, maxWidth, minHeight, maxHeight)

  local width, height = 40, 40
  local changeDirectionModifier = 30
  local sparsenessModifier = 25
  local deadEndRemovalModifier = 90
  local generator = astray.Astray:new(
    width/2-1, 
    height/2-1,
    changeDirectionModifier,
    sparsenessModifier,
    deadEndRemovalModifier,
    astray.RoomGenerator:new(10, 2, 4, 2, 4)
  )
  local map = generator:Generate()
  local tiles = generator:CellToTiles(map)


  -- for y = 0, #tiles[1] do
  --   local scaledRow = {}
  --   local row = tiles[y]
  --   for x=0,#tiles do
  --     print("Inserting...", tiles[y][x])
  --     table.insert(scaledRow, tiles[y][x])
  --   end
  --   table.insert(scaledMap, scaledRow)
  -- end
  local scalingFactor = 2
  local scaledMap = {}

  for y = 0, #tiles[1] do
    for iy=1,scalingFactor do
      local scaledRow = {}
      local row = tiles[y]
      for x=0,#tiles do
        for ix=1,scalingFactor do
          --print("Inserting...", tiles[y][x])
          table.insert(scaledRow, tiles[y][x])
        end
      end
      table.insert(scaledMap, scaledRow)
    end
  end

  for y = 0, #tiles[1] do
    local line = ''
    for x = 0, #tiles do
      line = line .. tiles[y][x]
    end
    --print(line)
  end

  return {
    tileSize = tileSize,
    size = { x = width * scalingFactor, y = height * scalingFactor },
    mapData = map,
    tiles = scaledMap
  }
end

    -- layers = {
    --   {
    --     name = 'background',
    --     tiles = functional.generate_2d(widthTiles, heightTiles, function(x, y)
    --       return {
    --         spriteId = 'tiles.ground_1',
    --         x = x - 1,
    --         y = y - 1
    --       }
    --     end)
    --   }
    -- },
    -- entities = functional.generate(20, function(i)
    --   return {
    --     components = {
    --       {
    --         name = 'sprite',
    --         properties = { 'tiles.wall_1' }
    --       },
    --       {
    --         name = 'position',
    --         properties = {
    --           love.math.random(widthTiles) * tileSize,
    --           love.math.random(heightTiles) * tileSize
    --         }
    --       },
    --       {
    --         name = 'gridCollisionItem'
    --       },
    --       {
    --         name = 'physicsBody',
    --         properties = { 70, { 'wall' }, { 'wall' }, true }
    --       }
    --     }
    --   }
    -- end)
    --   }
    -- end

return MapManager

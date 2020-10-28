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
    local entity = Concord.entity(world)
      :give("position", x * tileSize, y * tileSize)
      :give("sprite", tileValueToMediaId[tileValue])
      :give("gridCollisionItem", x, y)

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
  love.graphics.setCanvas(canvas)

  for y = 1, #tiles[1] do
    local line = ''
    for x = 1, #tiles do
      local tileValue = tiles[y][x]
      local tileHandler = handleTile[tileValue]
      if tileHandler then
        tileHandler(x, y, tileValue, tileSize, world)
      end
    end
  end

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
    self.collisionMap[y][x] = value
  end,

  getCollisionMap = function(self)
    return self.collisionMap
  end,

  setMap = function(self, map, world)
    --print("Setting map", inspect(map))
    
    clearEntities({self.floorEntity})
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

  local width, height = 14, 14
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

  local scalingFactor = 2
  local scaledMap = {}

  for y = 0, #tiles[1] do
    for iy=1,scalingFactor do
      local scaledRow = {}
      local row = tiles[y]
      for x=0,#tiles do
        for ix=1,scalingFactor do
          table.insert(scaledRow, tiles[y][x])
        end
      end
      table.insert(scaledMap, scaledRow)
    end
  end

  return {
    tileSize = tileSize,
    size = { x = width * scalingFactor, y = height * scalingFactor },
    mapData = map,
    tiles = scaledMap
  }
end

return MapManager

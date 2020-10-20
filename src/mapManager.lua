local positionUtil = require 'utils.position'

local function isPositionAvailable(self, x, y)
  return self.collisionMap[positionUtil.positionToString(x, y)]
end

local function drawCanvas(map, tiles, canvasSizeX, canvasSizeY)
  local tileSize = map.tileSize
  local canvas = love.graphics.newCanvas(canvasSizeX, canvasSizeY)
  print("size of canvas", canvasSizeX, canvasSizeY)
  love.graphics.setCanvas(canvas)

  for _, tile in ipairs(tiles) do
    local mediaEntity = mediaManager:getMediaEntity(tile.spriteId)
    --print("spriteId", tile.spriteId, inspect(mediaEntity))
    local finalX = tile.x * tileSize
    local finalY = tile.y * tileSize
    love.graphics.draw(mediaEntity.atlas, mediaEntity.quad, finalX, finalY)
  end

  love.graphics.setCanvas()
  return canvas
end

local function drawLayersToCache(map)
  local tileSize = map.tileSize
  local layerSprites = {}

  for _, layer in ipairs(map.layers) do
    local canvas = drawCanvas(map, layer.tiles,
    positionUtil.gridToPixels(map.size.x, map.size.y))
    local w, h = canvas:getDimensions()
    local quad = love.graphics.newQuad(0, 0, w, h, w, h)
    local mediaEntity = {
      atlas = canvas,
      quad = quad,
      metaData = {},
      origin = { x = 0, y = 0 }
    }

    local mediaPath = 'mapLayerCache.' .. layer.name
    mediaManager:setMediaEntity(mediaPath, mediaEntity)
    table.insert(layerSprites,
      Concord.entity()
      :give('sprite', mediaPath)
      :give('position', 0, 0)
    )
  end

  return layerSprites
end

local function clearLayerCache(map)
  if not map.layers then return end

  for _, layer in ipairs(map.layers) do
    mediaManager:removeMediaEntity('mapLayerCache.' .. layer.name)
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
    self.collisionMap[positionUtil.positionToString(x, y)] = value
  end,

  setMap = function(self, map, world)
    print("Setting map", self, map)
    clearEntities(self.entities)
    clearEntities(self.layerSprites)
    clearLayerCache(self.map)

    self.map = map
    self.layerSprites = drawLayersToCache(map)
    self.entities = initializeMapEntities(map)

    initializeEntities(world, self.layerSprites)
    initializeEntities(world, self.entities)
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


-- Generate test map. In reality you would have a map file made in tiled,
-- or some other sort of map editor.
MapManager.generateTestMap = function()
  local widthTiles = 30
  local heightTiles = 30

  local tileSize = 64

  return {
    tileSize = tileSize,
    size = { x = widthTiles, y = heightTiles },
    layers = {
      {
        name = 'background',
        tiles = functional.generate_2d(widthTiles, heightTiles, function(x, y)
          return {
            spriteId = 'tiles.ground_1',
            x = x - 1,
            y = y - 1
          }
        end)
      }
    },
    entities = functional.generate(20, function(i)
      return {
        components = {
          {
            name = 'sprite',
            properties = { 'tiles.wall_1' }
          },
          {
            name = 'position',
            properties = {
              love.math.random(widthTiles) * tileSize,
              love.math.random(heightTiles) * tileSize
            }
          },
          {
            name = 'gridCollisionItem'
          },
          {
            name = 'physicsBody',
            properties = { 70 }
          }
        }
      }
    end)
  }
end

return MapManager

local MapDrawSystem = Concord.system({})

local function draw(self)
  for _, canvasContainer in ipairs(self.canvasContainers) do
    local offsetY = canvasContainer.offset

    if not offsetY then
      offsetY = 0
    end

    love.graphics.draw(canvasContainer.canvas, 0, offsetY)
  end
end

local function getMapSizeInPixels(map)
  return map.size.x * map.tileSize, map.size.y * map.tileSize
end

local function drawCanvas(map, tiles, canvasSizeX, canvasSizeY)
  local tileSize = map.tileSize
  local canvas = love.graphics.newCanvas(canvasSizeX, canvasSizeY)
  love.graphics.setCanvas(canvas)

  for _, tile in ipairs(tiles) do
    local mediaEntity = mediaManager:getMediaEntity(tile.spriteId)
    local finalX = tile.x * tileSize
    local finalY = tile.y * tileSize
    love.graphics.draw(mediaManager:getAtlas(), mediaEntity.texture, finalX, finalY)
  end

  love.graphics.setCanvas()
  return {
    canvas = canvas
  }
end


local function drawCanvasRows(map, layer)
  local canvasSizeX, canvasSizeY = getMapSizeInPixels(map)
  local canvasContainers = {}

  for index, row in ipairs(layer.rows) do
    local canvasContainer = drawCanvas(map, row.tiles, #(row.tiles) * map.tileSize, map.tileSize*2)
    canvasContainer.offset = (index - 1) * map.tileSize
    table.insert(canvasContainers, canvasContainer)
  end

  return canvasContainers
end

local function drawLayersToCanvases(map)
  local canvasContainers = {}
  local tileSize = map.tileSize

  for _, layer in ipairs(map.layers) do
    local canvasContainer = {}
    local isZSorted = layer.isZSorted

    if isZSorted then
      tablex.append_inplace(canvasContainers, drawCanvasRows(map, layer))
    else
      tablex.insert(canvasContainers, drawCanvas(map, layer.tiles, getMapSizeInPixels(map)))
    end
  end

  return canvasContainers
end

local function initializeMapEntities(self, map)
  local entities = {}
  if not map.entities then return end
  for _, entityData in ipairs(map.entities) do
    local entity = Concord.entity(self:getWorld())
    if entityData.assemblageSelector then
      entity:assemble(ECS.a.getBySelector(entityData.assemblageSelector))
    elseif entityData.components then
      for _, component in ipairs(entityData.components) do
        entity:give(component.name, unpack(component.properties))
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

function MapDrawSystem:mapChange(map)
  clearEntities(self.entities)
  self.canvasContainers = drawLayersToCanvases(map)
  self.entities = initializeMapEntities(self, map)
end

function MapDrawSystem:init()
  self.entities = {}
end

function MapDrawSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", map, draw, self, 0)
end

return MapDrawSystem

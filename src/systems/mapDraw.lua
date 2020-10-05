local MapSystem = Concord.system({})

local function draw(self)
  for _, canvas in ipairs(self.canvases) do
    love.graphics.draw(canvas)
  end
end

local function drawLayersToCanvases(map)
  local canvases = {}
  local tileSize = map.tileSize

  for _, layer in ipairs(map.layers) do
    local pixelsX = map.size.x * tileSize
    local pixelsY = map.size.y * tileSize
    local canvas = love.graphics.newCanvas(pixelsX, pixelsY)
    love.graphics.setCanvas(canvas)

    for _, tile in ipairs(layer.tiles) do
      local mediaEntity = mediaManager:getMediaEntity(tile.spriteId)
      local finalX = tile.x * tileSize - tileSize
      local finalY = tile.y * tileSize - tileSize
      love.graphics.draw(mediaManager:getAtlas(), mediaEntity.texture, finalX, finalY)
    end

    love.graphics.setCanvas()
    table.insert(canvases, canvas)
  end

  return canvases
end

function MapSystem:mapChange(map)
  self.canvases = drawLayersToCanvases(map)
end

function MapSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", map, draw, self, 0)
end

return MapSystem

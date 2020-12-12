local Gamestate = require 'libs.hump.gamestate'

local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local function compareY(a, b)
  if a.sprite.zIndex ~= b.sprite.zIndex then
    return a.sprite.zIndex < b.sprite.zIndex
  end
  local mediaEntityA = mediaManager:getMediaEntity(a.sprite.spriteId)
  local mediaEntityB = mediaManager:getMediaEntity(b.sprite.spriteId)

  local _, _, _, h1 = mediaEntityA.quads[a.sprite.currentQuadIndex or 1]:getViewport()
  local _, _, _, h2 = mediaEntityB.quads[b.sprite.currentQuadIndex or 1]:getViewport()

  local posA = a.position.vec.y + h1 - mediaEntityA.origin.y * h1
  local posB = b.position.vec.y + h2 - mediaEntityB.origin.y * h2
  return posA < posB
end

function SpriteSystem:init()
  self.layers = {}
  self.pool.onEntityAdded = function(_, entity)
    local layerId = entity.sprite.layerId
    self.layers[layerId] = self.layers[layerId] or {}
    table.insert(self.layers[layerId], entity)
  end

  self.pool.onEntityRemoved = function(_, entity)
    local layerId = entity.sprite.layerId
    table.remove_value(self.layers[layerId], entity)
  end
end

function SpriteSystem:setCamera(camera)
  self.camera = camera
end

function SpriteSystem:screenEntitiesUpdated(entities)
  self.screenSpatialGroup = entities
end

local function drawLayer(self, layerId)
  if not self.camera then return end

  if not self.layers[layerId] then error("Trying to draw into non existing layer: " .. layerId) end
  local inHash = functional.filter(self.layers[layerId], function(entity)
    return functional.contains(self.screenSpatialGroup, entity)
  end)
  local zSorted = table.insertion_sort(inHash, function(a, b) return compareY(a, b) end)
  for _, entity in ipairs(zSorted) do
    local spriteId = entity.sprite.spriteId
    local mediaEntity = mediaManager:getMediaEntity(spriteId)

    local position = entity.position.vec
    local currentQuadIndex = entity.sprite.currentQuadIndex or 1
    local currentQuad = mediaEntity.quads[currentQuadIndex]
      _, _, w, h = currentQuad:getViewport()
    local origin = { x = 0, y = 0 }
    if mediaEntity.origin then
      origin.x = w * mediaEntity.origin.x
      origin.y = h * mediaEntity.origin.y
    end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(mediaEntity.atlas, currentQuad, position.x, position.y, 0, entity.sprite.scale, entity.sprite.scale, origin.x, origin.y)
    if Gamestate.current().debug then
      love.graphics.circle('fill', position.x, position.y, 2)
    end
  end
end

local function createDrawFunction(self, layerName)
  self.layers[layerName] = {}
  return function() drawLayer(self, layerName) end
end

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "ground", createDrawFunction(self, "ground"), self, true)
  self:getWorld():emit("registerLayer", "groundLevel", createDrawFunction(self, "groundDecals"), self, true)
  self:getWorld():emit("registerLayer", "onGround", createDrawFunction(self, "onGround"), self, true)
  self:getWorld():emit("registerLayer", "aboveGround", createDrawFunction(self, "aboveGround"), self, true)
end

return SpriteSystem

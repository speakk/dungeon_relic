local Gamestate = require 'libs.hump.gamestate'

local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local function compareY(a, b)
  if a.sprite.zIndex ~= b.sprite.zIndex then
    return a.sprite.zIndex < b.sprite.zIndex
  end
  local mediaEntityA = mediaManager:getMediaEntity(a.sprite.spriteId)
  local mediaEntityB = mediaManager:getMediaEntity(b.sprite.spriteId)

  local _, h1 = mediaEntityA.quads[a.sprite.currentQuadIndex or 1]:getTextureDimensions()
  local _, h2 = mediaEntityB.quads[b.sprite.currentQuadIndex or 1]:getTextureDimensions()
  --local posA = a.position.vec.y - mediaEntityA.origin.y * h1 / 2 + h1
  --local posB = b.position.vec.y - mediaEntityB.origin.y * h2 / 2 + h2
  local posA = a.position.vec.y + h1
  local posB = b.position.vec.y + h2
  return posA < posB

  --return a.position.vec.y < b.position.vec.y
end

function SpriteSystem:setCamera(camera)
  self.camera = camera
end

local function draw(self)
  if not self.camera then return end

  local l, t, w, h = self.camera:getVisible()

  local screenSpatialGroup = {}
  Gamestate.current().spatialHash:each(l, t, w, h, function(entity)
    table.insert(screenSpatialGroup, entity)
  end)

  local inHash = functional.filter(self.pool, function(entity)
    return functional.contains(screenSpatialGroup, entity)
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

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", "sprite", draw, self, 1)
end

function SpriteSystem:mapChange(map)
  self.tileSize = map.tileSize
end

return SpriteSystem

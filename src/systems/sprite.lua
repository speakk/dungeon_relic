local Gamestate = require 'libs.hump.gamestate'

local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local function compareY(a, b)
  if a.sprite.zIndex ~= b.sprite.zIndex then
    return a.sprite.zIndex < b.sprite.zIndex
  end
  local spriteA = mediaManager:getMediaEntity(a.sprite.spriteId)
  local spriteB = mediaManager:getMediaEntity(b.sprite.spriteId)

  local posA = a.position.vec.y + spriteA.origin.y
  local posB = b.position.vec.y + spriteB.origin.y

  return posA < posB
end

function SpriteSystem:setCamera(camera)
  self.camera = camera
end

local function draw(self)
  if not self.camera then return end

  --self.tilesetBatch:clear()

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
    --local _, _, quadWidth, quadHeight = mediaEntity.quad:getViewport()
    --local origin = Vector(mediaEntity.origin.x - quadWidth / 2, mediaEntity.origin.y - quadHeight)
    local origin = Vector(0, 0)

    local finalPosition = position - origin

    if mediaEntity.atlas then
      love.graphics.draw(mediaEntity.atlas, mediaEntity.quad, finalPosition.x, finalPosition.y, 0, entity.sprite.scale, entity.sprite.scale)
    else
      love.graphics.draw(mediaEntity.image, finalPosition.x, finalPosition.y, 0, entity.sprite.scale, entity.sprite.scale)

    end
  end
end

function SpriteSystem:init()
  self.tilesetBatch = love.graphics.newSpriteBatch(mediaManager:getAtlas(), 500)
end

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", "sprite", draw, self, 1)
end

function SpriteSystem:mapChange(map)
  self.tileSize = map.tileSize
end

return SpriteSystem

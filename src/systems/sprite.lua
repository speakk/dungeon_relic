local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local sortPool = {}

local function compareY(a, b, cellSize)
  local spriteA = mediaManager:getMediaEntity(a.sprite.spriteId)
  local spriteB = mediaManager:getMediaEntity(b.sprite.spriteId)

  local posA = a.position.vec.y + spriteA.origin.y
  local posB = b.position.vec.y + spriteB.origin.y
  --print("Comparing origins:", spriteA.origin.y, spriteB.origin.y)
  return posA < posB
end

local function draw(self)
  self.tilesetBatch:clear()

  local zSorted = table.insertion_sort(sortPool, function(a, b) return compareY(a, b, self.tileSize) end)
  for _, entity in ipairs(zSorted) do
    local spriteId = entity.sprite.spriteId
    local mediaEntity = mediaManager:getMediaEntity(spriteId)

    local position = entity.position.vec
    --local origin = Vector(mediaEntity.origin.x, mediaEntity.origin.y)
    local origin = Vector(0, 0)

    local finalPosition = position - origin

    love.graphics.draw(mediaManager:getAtlas(), mediaEntity.texture, finalPosition.x, finalPosition.y)
  end
end

function SpriteSystem:init()
  self.tilesetBatch = love.graphics.newSpriteBatch(mediaManager:getAtlas(), 500)

  self.pool.onEntityAdded = function(_, entity)
    table.insert(sortPool, entity)
  end

  self.pool.onEntityRemoved = function(_, entity)
    lume.remove(sortPool, entity)
  end
end

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", "sprite", draw, self, 1)
end

function SpriteSystem:mapChange(map)
  self.tileSize = map.tileSize
end

return SpriteSystem

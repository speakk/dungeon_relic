local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local function draw(self)
  for _, entity in ipairs(self.pool) do
    local spriteId = entity.sprite.spriteId
    local mediaEntity = mediaManager:getMediaEntity(spriteId)

    local position = entity.position.vec
    local origin = Vector(unpack(mediaEntity.origin))

    local finalPosition = position + origin

    love.graphics.draw(mediaManager:getAtlas(), mediaEntity.texture, finalPosition.x, finalPosition.y)
  end
end

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerDrawCallback", "sprite", draw, self, 1)
end

return SpriteSystem

local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

function draw(self)
  for _, entity in ipairs(self.pool) do
    local spriteId = entity.sprite.spriteId
    local mediaEntity = mediaManager:getMediaEntity(spriteId)

    local position = entity.position.vec
    local origin = Vector(unpack(mediaEntity.origin))

    local finalPosition = position + origin

    love.graphics.draw(mediaManager:getAtlas(), mediaEntity.texture, finalPosition.x, finalPosition.y)
  end
end

function SpriteSystem:init(world)
  local drawSystem = world:getSystem(ECS.s.draw)
  drawSystem:registerDrawCallback("sprite", draw, self, 0)
end

return SpriteSystem

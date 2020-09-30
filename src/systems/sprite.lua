local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

function draw(self)
  for _, entity in ipairs(self.pool) do
    local spriteId = entity.sprite.spriteId
    local position = entity.position.vec

    love.graphics.draw(mediaManager:getAtlas(), mediaManager:getTexture(spriteId), position.x, position.y)
  end
end

function SpriteSystem:init(world)
  local drawSystem = world:getSystem(ECS.s.draw)
  drawSystem:registerDrawCallback("sprite", draw, self, 0)
end

return SpriteSystem

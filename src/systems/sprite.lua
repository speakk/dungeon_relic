local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local playerImage = love.graphics.newImage('media/images/player.png')

function draw(self)
  for _, entity in ipairs(self.pool) do
    local sprite = entity.sprite
    local position = entity.position.vec

    love.graphics.draw(playerImage, position.x, position.y)
  end
end

function SpriteSystem:init(world)
  local drawSystem = world:getSystem(ECS.s.draw)
  drawSystem:registerDrawCallback("sprite", draw, self, 0)
end

return SpriteSystem

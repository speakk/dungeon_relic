local game = {}

local TESTING = true

function game:enter()
  self.world = Concord.world()
  self.world:addSystems(
    ECS.s.draw,
    ECS.s.sprite
  )

  if TESTING then
    self.world:emit('initTest')

    local entity = Concord.entity(self.world)
    entity:give("sprite")
    entity:give("position", 10, 20)
    local entity2 = Concord.entity(self.world)
    entity2:give("sprite")
    entity2:give("position", 150, 50)

    print("Get image", inspect(mediaManager:getImg('player')))
  end
end

function game:leave()
  self.world:clear()
end

function game:update(dt)
  self.world:emit("update", dt)
end

function game:draw()
  self.world:emit("draw")
end

return game

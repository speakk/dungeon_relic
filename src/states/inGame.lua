local game = {}

local TESTING = true

function game:enter()
  self.world = Concord.world()
  self.world:addSystems(
    ECS.s.input,
    ECS.s.playerControlled,
    ECS.s.movement,
    ECS.s.draw,
    ECS.s.sprite
  )

  if TESTING then
    self.world:emit('initTest')

    local entity = Concord.entity(self.world)
    entity:give("sprite", 'characters.player')
    entity:give("position", 10, 20)
    entity:give("velocity", 0, 0)
    entity:give("acceleration", 0, 0)
    entity:give("playerControlled")
    local entity2 = Concord.entity(self.world)
    entity2:give("sprite", "characters.secondball")
    entity2:give("position", 150, 50)
  end
end

function game:leave()
  self.world:clear()
end

function game:update(dt)
  self.world:emit("clearVelocities", dt)
  self.world:emit("update", dt)
end

function game:draw()
  self.world:emit("draw")
end

return game

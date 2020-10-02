local PlayerControlledSystem = Concord.system({ pool = { "playerControlled", "direction" } })

function PlayerControlledSystem:moveLeft()
  for i=1,#self.pool do
    local entity = self.pool[i]
    entity.direction.vec.x = -1
  end
end

function PlayerControlledSystem:moveRight()
  for i=1,#self.pool do
    local entity = self.pool[i]
    entity.direction.vec.x = 1
  end
end

function PlayerControlledSystem:moveUp()
  for i=1,#self.pool do
    local entity = self.pool[i]
    entity.direction.vec.y = -1
  end
end

function PlayerControlledSystem:moveDown()
  for i=1,#self.pool do
    local entity = self.pool[i]
    entity.direction.vec.y = 1
  end
end

return PlayerControlledSystem

local PlayerControlledSystem = Concord.system({ pool = { "playerControlled", "direction" } })

function PlayerControlledSystem:moveLeft()
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.x = -1
  end
end

function PlayerControlledSystem:moveRight()
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.x = 1
  end
end

function PlayerControlledSystem:moveUp()
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.y = -1
  end
end

function PlayerControlledSystem:moveDown()
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.y = 1
  end
end

return PlayerControlledSystem

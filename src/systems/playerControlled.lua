local PlayerControlledSystem = Concord.system({ pool = { 'playerControlled', 'directionIntent' } })

function PlayerControlledSystem:moveLeft()
  for _, entity in ipairs(self.pool) do
    entity.directionIntent.vec.x = -1
  end
end

function PlayerControlledSystem:moveRight()
  for _, entity in ipairs(self.pool) do
    entity.directionIntent.vec.x = 1
  end
end

function PlayerControlledSystem:moveUp()
  for _, entity in ipairs(self.pool) do
    entity.directionIntent.vec.y = -1
  end
end

function PlayerControlledSystem:moveDown()
  for _, entity in ipairs(self.pool) do
    entity.directionIntent.vec.y = 1
  end
end

function PlayerControlledSystem:playerShoot()
  for _, entity in ipairs(self.pool) do
    self:getWorld():emit("shoot", entity, entity.position.vec, entity.directionIntent.vec, "bullets.basicBullet", { "player" })
  end
end

return PlayerControlledSystem

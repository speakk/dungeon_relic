local MovementSystem = Concord.system({ pool = { "velocity", "acceleration", "direction", "position" } })

function MovementSystem:clearMovementIntent(dt)
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.length = 0
    entity.acceleration.vec.length = 0
  end
end

function MovementSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    -- Right now just copy direction -> acceleration. here. TODO: Move direction -> acceleration relationship into its own system
    entity.acceleration.vec = entity.direction.vec.copy
    entity.velocity.vec = entity.velocity.vec + entity.acceleration.vec
    entity.position.vec = entity.position.vec + entity.velocity.vec * dt * entity.speed.value
    applyFriction2d(entity.velocity.vec, 15, dt)
  end
end

-- Friction code yoink'd from the batteries vec lib.

function applyFriction1d(value, mu, dt)
  local friction = mu * value * dt
  if math.abs(friction) > math.abs(value) then
    return 0
  else
    return value - friction
  end
end

function applyFriction2d(vector, mu, dt)
  vector.x = applyFriction1d(vector.x, mu, dt)
  vector.y = applyFriction1d(vector.y, mu, dt)
end

return MovementSystem

local MovementSystem = Concord.system({
  pool = { "velocity", "directionIntent", "position" },
  clearDirectionIntents = { "clearDirectionIntent", "directionIntent" }
})

function MovementSystem:clearDirectionIntent(_)
  for _, entity in ipairs(self.clearDirectionIntents) do
    entity.directionIntent.vec.length = 0
  end
end

function MovementSystem:mapChange(map)
  local tileSize = map.tileSize
  self.mapBounds = {
    min = Vector(map.tileSize, map.tileSize),
    max = Vector((map.size.x + 1) * tileSize, (map.size.y + 1) * tileSize)
  }
end

-- Friction code yoink'd from the batteries vec lib.

local function applyFriction1d(value, mu, dt)
  local friction = mu * value * dt
  if math.abs(friction) > math.abs(value) then
    return 0
  else
    return value - friction
  end
end

local function applyFriction2d(vector, mu, dt)
  vector.x = applyFriction1d(vector.x, mu, dt)
  vector.y = applyFriction1d(vector.y, mu, dt)
end

function MovementSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    -- Right now just copy directionIntent -> acceleration. here. TODO: Move directionIntent -> acceleration relationship into its own system
    local acceleration = entity.directionIntent.vec.copy
    entity.velocity.vec = entity.velocity.vec + acceleration
    entity.position.vec.x, entity.position.vec.y = Vector.split(entity.position.vec + entity.velocity.vec * dt * entity.speed.value)
    applyFriction2d(entity.velocity.vec, 15, dt)
  end
end

return MovementSystem

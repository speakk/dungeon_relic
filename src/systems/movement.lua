local MovementSystem = Concord.system({ pool = { "velocity", "acceleration", "direction", "position" } })

function MovementSystem:clearMovementIntent(_)
  for _, entity in ipairs(self.pool) do
    entity.direction.vec.length = 0
    entity.acceleration.vec.length = 0
  end
end

function MovementSystem:mapChange(map)
  local tileSize = map.tileSize
  self.mapBounds = {
    min = Vector(0, 0),
    max = Vector(map.size.x * tileSize, map.size.y * tileSize)
  }

  print("mapBounds", self.mapBounds.min, self.mapBounds.max)
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
    local oldPosition = entity.position.vec.copy
    -- Right now just copy direction -> acceleration. here. TODO: Move direction -> acceleration relationship into its own system
    entity.acceleration.vec = entity.direction.vec.copy
    entity.velocity.vec = entity.velocity.vec + entity.acceleration.vec
    entity.position.vec = entity.position.vec + entity.velocity.vec * dt * entity.speed.value
    applyFriction2d(entity.velocity.vec, 15, dt)

    local position = entity.position.vec
    local velocity = entity.velocity.vec
    local sizeVec = entity.size and entity.size.vec or Vector(0, 0)
    if position.x < self.mapBounds.min.x then position.x = self.mapBounds.min.x velocity.x = 0 end
    if position.y < self.mapBounds.min.y then position.y = self.mapBounds.min.y velocity.y = 0 end
    if position.x > self.mapBounds.max.x - sizeVec.x then position.x = self.mapBounds.max.x - sizeVec.x velocity.x = 0 end
    if position.y > self.mapBounds.max.y - sizeVec.y then position.y = self.mapBounds.max.y - sizeVec.y velocity.y = 0 end

    -- local sizeVec = entity.size and entity.size.vec or Vector(0, 0)
    -- entity.position.vec = entity.position.vec:clamp(self.mapBounds.min, self.mapBounds.max - sizeVec)
    -- local diff = entity.position.vec - oldPosition
    -- entity.velocity.vec = entity.velocity.vec:clamp(-diff, diff)
    -- print("diff",diff, entity.velocity.vec)
    -- --entity.velocity.vec = diff
    -- --entity.velocity.vec = (entity.position.vec + entity.velocity.vec):clamp(self.mapBounds.min, self.mapBounds.max - sizeVec) - entity.position.vec
  end
end

return MovementSystem

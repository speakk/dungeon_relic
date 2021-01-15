local FrictionSystem = Concord.system({ pool = { "friction" } })

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

function FrictionSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    applyFriction2d(entity.velocity.vec, 5, dt)
  end
end

return FrictionSystem


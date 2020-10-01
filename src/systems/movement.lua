local MovementSystem = Concord.system({ pool = { "velocity", "acceleration", "position" } })

local SPEED = 300 -- TODO: Make speed based on component

function MovementSystem:clearVelocities(dt)
  for _, entity in ipairs(self.pool) do
    entity.acceleration.vec:smuli(0, 0)
  end
end

function MovementSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.velocity.vec:vaddi(entity.acceleration.vec)
    entity.velocity.vec:mini(vec2(10, 10))
    --entity.velocity.vec:normalisei() -- Use velocity more as a direction vector (TODO: Implement better movement)
    entity.position.vec:vaddi(entity.velocity.vec:smuli(SPEED, SPEED):smuli(dt, dt))
    entity.velocity.vec:apply_friction_xy(40, 40, dt)
  end
end

return MovementSystem

local flux = require 'libs.flux'

local HealthSystem = Concord.system({ pool = { "health" }})

function HealthSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity.health.countDown = 0
  end
end

function HealthSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    local health = entity.health
    health.countDown = health.countDown - dt
    if health.countDown < 0 then health.countDown = 0 end
  end
end


function HealthSystem:takeDamage(target, damage)
  if target.physicalImmunity then return end

  if functional.contains(self.pool, target) then
    if target.health.countDown == 0 then
      target.health.countDown = target.health.damageCooldown
      self:getWorld():emit("setHealth", target, target.health.value - damage)
      target.sprite.whiteAmount = 1
      flux.to(target.sprite, 0.3, { whiteAmount = 0 })

      local spurt = Concord.entity(self:getWorld())
      spurt:give('sprite', 'decals.blood.spurt' .. love.math.random(1, 3), "groundLevel", nil, 1)
      :give('position', Vector.split(target.position.vec))
      :give('selfDestroy', 200)

      Concord.entity(self:getWorld())
      :give('text', damage)
      :give('position', Vector.split(target.position.vec))
      :give("selfDestroy", 40)
      :give("directionIntent", 0, -1)
      :give("speed", 200)
      :give("velocity", 0, 0)


      if target.health.value < 0 then
        self:getWorld():emit("healthReachedZero", target)
      end
    end
  end
end

function HealthSystem:setHealth(entity, newValue)
  entity.health.value = newValue
  self:getWorld():emit("healthChanged", entity, entity.health.value)
end

return HealthSystem


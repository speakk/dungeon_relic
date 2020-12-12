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
  if functional.contains(self.pool, target) then
    if target.health.countDown == 0 then
      target.health.countDown = target.health.damageCooldown
      self:getWorld():emit("setHealth", target, target.health.value - damage)

      local spurt = Concord.entity(self:getWorld())
      spurt:give('sprite', 'decals.blood.spurt' .. love.math.random(1, 3), "aboveGround", nil, 1)
      :give('position', Vector.split(target.position.vec))
      :give('selfDestroy', 200)

      Concord.entity(self:getWorld()):assemble(ECS.a.getBySelector('particle_emitters.smallDamageHit'))
      :give('position', Vector.split(target.position.vec))

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


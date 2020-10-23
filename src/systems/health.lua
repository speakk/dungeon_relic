local HealthSystem = Concord.system({ pool = { "health" }})

function HealthSystem:takeDamage(target, damage)
  if functional.contains(self.pool, target) then
    target.health.value = target.health.value - damage

    local spurt = Concord.entity(self:getWorld())
    spurt:give('sprite', 'decals.blood.spurt' .. love.math.random(1, 3), 1, 3)
    :give('position', Vector.split(target.position.vec))
    :give('selfDestroy', 20000)

    if target.health.value < 0 then
      self:getWorld():emit("healthReachedZero", target)
    end
  end
end

return HealthSystem


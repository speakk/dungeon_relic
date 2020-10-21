local HealthSystem = Concord.system({ pool = { "health" }})

function HealthSystem:takeDamage(target, damage)
  if functional.contains(self.pool, target) then
    target.health.value = target.health.value - damage

    if target.health.value < 0 then
      self:getWorld():emit("healthReachedZero", target)
    end
  end
end

return HealthSystem


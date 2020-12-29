local DeathSystem = Concord.system({})

function DeathSystem:healthReachedZero(target)
  local splat = Concord.entity(self:getWorld())
  splat:give('sprite', 'decals.blood.splat' .. love.math.random(1, 3), "groundLevel")
  splat:give('origin', 0.5, 0.5)
  splat:give('position', Vector.split(target.position.vec))
  splat:give('selfDestroy', 3000)

  target:destroy()
end

return DeathSystem



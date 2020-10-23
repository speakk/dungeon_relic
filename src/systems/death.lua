local DeathSystem = Concord.system({})

function DeathSystem:healthReachedZero(target)
  local splat = Concord.entity(self:getWorld())
  splat:give('sprite', 'decals.blood.splat' .. love.math.random(1, 3))
  splat:give('position', Vector.split(target.position.vec))
  splat:give('selfDestroy', 200)

  target:destroy()
end

return DeathSystem



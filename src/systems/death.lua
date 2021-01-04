local flux = require 'libs.flux'

local DeathSystem = Concord.system({})

function DeathSystem:healthReachedZero(target)
  local splat = Concord.entity(self:getWorld())
  splat:give('sprite', 'decals.blood.splat' .. love.math.random(1, 3), "groundLevel")
  splat:give('origin', 0.5, 0.5)
  splat:give('position', Vector.split(target.position.vec))
  splat:give('selfDestroy', 3000)

  if target.simpleAnimation and target.simpleAnimation.death then
    print("Had death anim")
    local anim = target.simpleAnimation.death
    self:getWorld():emit("removeStateMachineComponent", target)
    self:getWorld():emit("removePhysicsComponent", target)
    target:remove("animation")
    target:remove("velocity")
    target:remove("speed")
    target.sprite.currentQuadIndex = anim.from
    flux.to(target.sprite, anim.duration, { currentQuadIndex = anim.to })
    :oncomplete(function()
    end)
  else
    target:destroy()
  end
end

return DeathSystem



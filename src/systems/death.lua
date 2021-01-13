local flux = require 'libs.flux'

local DeathSystem = Concord.system({ pool = { "dead" }})

function DeathSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    self:getWorld():emit("removeStateMachineComponent", entity)
    --self:getWorld():emit("removePhysicsComponent", entity)
    entity:remove("physicsBody")
    entity:remove("animation")
    entity:remove("velocity")
    entity:remove("speed")

    if entity.simpleAnimation and entity.simpleAnimation.death then
      print("Had death anim")
      local anim = entity.simpleAnimation.death
      entity.sprite.currentQuadIndex = anim.from
      flux.to(entity.sprite, anim.duration, { currentQuadIndex = anim.to })
      :oncomplete(function()
      end)
    else
      entity:destroy()
    end

  end
end

function DeathSystem:healthReachedZero(target)
  local splat = Concord.entity(self:getWorld())
  splat:give('sprite', 'decals.blood.splat' .. love.math.random(1, 3), "groundLevel")
  splat:give('origin', 0.5, 0.5)
  splat:give('position', Vector.split(target.position.vec))
  splat:give('selfDestroy', 3000)

  target:give("dead")
end

return DeathSystem



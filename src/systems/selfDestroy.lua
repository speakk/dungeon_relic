local SelfDestroySystem = Concord.system({ pool = { "selfDestroy" } })

function SelfDestroySystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.selfDestroy.time = entity.selfDestroy.time - 100 * dt

    if entity.selfDestroy.time <= 0 then
      entity:destroy()
    end
  end
end

return SelfDestroySystem


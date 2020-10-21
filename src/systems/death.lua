local DeathSystem = Concord.system({})

function DeathSystem:healthReachedZero(target)
  target:destroy()
end

return DeathSystem



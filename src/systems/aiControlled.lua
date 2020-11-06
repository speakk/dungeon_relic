local AIControlledSystem = Concord.system({
  pool = { "aiControlled", "directionIntent" },
  players = { "playerControlled", "position" }
})

-- Stop jittering if object is right on top of the other
local stopFollowingDistance = 2

function AIControlledSystem:update(dt)
  -- Make AI follow the player
  -- For now just picks first in players array
  -- TODO: Make it follow the closest player

  local target = self.players[1]

  if not target then return end

  for _, entity in ipairs(self.pool) do
    local difference = (target.position.vec - entity.position.vec)
    if difference.length > stopFollowingDistance then
      entity.directionIntent.vec = difference.normalized
    end
  end
end

return AIControlledSystem

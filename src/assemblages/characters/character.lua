return function(entity, x, y)
  entity:give("position", x, y)
  entity:give("size", 32, 50) -- TODO: do not hard code this
  entity:give("velocity")
  entity:give("directionIntent")
  entity:give("clearDirectionIntent")
  -- TODO: Remove { "player" } from ignoreGroups, using it to make ease of movement better
  entity:give("physicsBody", 16, 16, nil, { "player" })
  entity:give("health", 100)
end

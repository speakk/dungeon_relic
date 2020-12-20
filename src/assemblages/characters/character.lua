return function(entity, x, y)
  entity:give("position", x, y)
  entity:give("size", 32, 50) -- TODO: do not hard code this
  entity:give("velocity")
  entity:give("dropShadow")
  entity:give("origin", 0.5, 0.95)
  entity:give("directionIntent")
  entity:give("clearDirectionIntent")
  -- TODO: Remove { "player" } from ignoreGroups, using it to make ease of movement better
  entity:give("health", 100)
end

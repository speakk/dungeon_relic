return function(entity, x, y)
  entity:give("position", x, y)
  entity:give("size", 32, 50) -- TODO: do not hard code this
  entity:give("velocity")
  entity:give("directionIntent")
  entity:give("clearDirectionIntent")
  entity:give("physicsBody", 13)
end

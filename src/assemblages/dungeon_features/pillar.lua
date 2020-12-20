return function(entity)
  entity:give("sprite", "dungeon_features.pillar", "onGround")
  entity:give("physicsBody", {
    width = 0.4,
    height = 0.2,
    offsetX = 0.5,
    offsetY = 0.9,
    static = true
  })
  entity:give("dropShadow")
  entity:give("origin", 0.5, 0.95)
end


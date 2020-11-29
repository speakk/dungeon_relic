return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("aiControlled")
  entity:give("speed", 20)
  entity:give("damager", 20)
  entity:give("health", 30)
  entity:give("sprite", 'characters.monster_B')

  entity:give("physicsBody", {
    width = 1,
    height = 1,
    centered = true,
    tags = { "monster" },
    collisionEvent = { name = "monsterCollision", targetTags = { "player" } }
  })
end


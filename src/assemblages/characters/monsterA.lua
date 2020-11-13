return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("aiControlled")
  entity:give("speed", 20)
  entity:give("damager", 20)
  entity:give("health", 30)
  entity:give("sprite", 'characters.monster_B')
  entity:give("physicsBody", 16, 16, { "monster" }, nil, nil, {
    name = "monsterCollision", targetTags = { "player" } })
end


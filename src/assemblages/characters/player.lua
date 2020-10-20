return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("playerControlled")
  entity:give("speed", 300)
  entity:give("sprite", 'characters.player')
  entity:give("cameraTarget")
  entity:give("physicsBody", 13, { "player" })
end

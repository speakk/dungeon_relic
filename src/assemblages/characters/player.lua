return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, 700, 700)
  entity:give("playerControlled")
  entity:give("speed", 40)
  entity:give("size", 20, 32)
  entity:give("sprite", 'characters.player2')
  entity:give("cameraTarget")
  entity:give("physicsBody", 13, 13, { "player" })
end

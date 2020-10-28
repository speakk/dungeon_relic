return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, 300, 300)
  entity:give("playerControlled")
  entity:give("speed", 200)
  entity:give("sprite", 'characters.player')
  entity:give("cameraTarget")
  entity:give("physicsBody", "circle", { radius = 13 }, { "player" })
end

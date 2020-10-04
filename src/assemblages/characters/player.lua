return function(entity, position)
  entity:assemble(ECS.a.characters.character, position)
  entity:give("playerControlled")
  entity:give("speed", 300)
  entity:give("sprite", 'characters.player')
  entity:give("cameraTarget")
end

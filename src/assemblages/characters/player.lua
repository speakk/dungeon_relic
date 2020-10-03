return function(entity, position)
  entity:assemble(ECS.a.characters.character, position)
  entity:give("playerControlled")
  entity:give("sprite", 'characters.player')
end

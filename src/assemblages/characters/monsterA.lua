return function(entity, position)
  entity:assemble(ECS.a.characters.character, position)
  entity:give("aiControlled")
  entity:give("sprite", 'characters.secondball')
end


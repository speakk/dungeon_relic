return function(entity, position)
  entity:assemble(ECS.a.characters.character, position)
  entity:give("aiControlled")
  entity:give("speed", 150)
  entity:give("sprite", 'characters.monster_A')
end


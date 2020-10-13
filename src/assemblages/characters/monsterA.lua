return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("aiControlled")
  entity:give("speed", 150)
  entity:give("sprite", 'characters.monster_B')
end


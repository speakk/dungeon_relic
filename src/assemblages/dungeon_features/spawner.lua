return function(entity)
  entity:give("sprite", "dungeon_features.spawner", 2)
  entity:give("spawner", 5, { "characters.monsterA" }, true)
  entity:give("health", 100)
  entity:give("physicsBody", 32, 32, nil, { "monster" }, true)
end


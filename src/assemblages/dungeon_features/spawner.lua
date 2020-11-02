return function(entity)
  entity:give("sprite", "dungeon_features.spawner")
  entity:give("spawner", 1, { "characters.monsterA" }, true)
  entity:give("health", 100)
  entity:give("physicsBody", 32, 32)
end


return function(entity)
  entity:give("sprite", "dungeon_features.spawner", 0)
  entity:give("spawner", 5, { "characters.monsterA" }, true)
  entity:give("health", 100)
  entity:give("physicsBody", {
    width = 32,
    height = 32,
    targetIgnoreTags = { "monster" },
    static = true
  })
end


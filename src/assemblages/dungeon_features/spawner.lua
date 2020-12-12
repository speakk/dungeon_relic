return function(entity)
  entity:give("sprite", "dungeon_features.spawner", 0, "groundLevel")
  entity:give("spawner", 5, { "characters.monsterA" }, true)
  entity:give("health", 100)
  entity:give("physicsBody", {
    width = 1,
    height = 1,
    cornerOrigin = true,
    targetIgnoreTags = { "monster" },
    static = true
  })
end


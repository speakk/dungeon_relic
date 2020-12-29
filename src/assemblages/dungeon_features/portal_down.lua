return function(entity)
  entity:give("sprite", 'dungeon_features.portal', "groundLevel")
  entity:give("interactable", "Press space to descend", { name = "descendLevel", properties = { direction = "down" }})
  entity:give("origin", 0.5, 0.5)
  entity:give("physicsBody", {
    width = 0.9,
    height = 0.85,
    offsetX = 0.5,
    offsetY = 0.5,
    static = true,
    cornerOrigin = true
  })
end

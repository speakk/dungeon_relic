return function(entity)
  entity:give("sprite", 'dungeon_features.portal_up', "onGround")
  entity:give("interactable", "Press space to ascend", { name = "ascendLevel", properties = { direction = "up" }})
  entity:give("origin", 0.5, 0.5)
  entity:give("portal", "up")
  entity:give("physicsBody", {
    width = 0.9,
    height = 0.65,
    static = true,
    offsetX = 0.5,
    offsetY = 0.9
  })
end

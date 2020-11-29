return function(entity)
  entity:give("sprite", 'dungeon_features.portal')
  entity:give("physicsBody", {
    width = 0.4,
    height = 0.4,
    offsetX = 0.5,
    offsetY = 0.5,
    cornerOrigin = true,
    collisionEvent = { name = "portalTouched", properties = { direction = "down" } }
  })
end

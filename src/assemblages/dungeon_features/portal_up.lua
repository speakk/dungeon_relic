return function(entity)
  entity:give("sprite", 'dungeon_features.portal_up')
  entity:give("physicsBody", {
    width = 0.9,
    height = 0.9,
    cornerOrigin = true,
    collisionEvent = { name = "portalTouched", properties = { direction = "up" } }
  })
end

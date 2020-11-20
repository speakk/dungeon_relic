return function(entity)
  entity:give("sprite", 'dungeon_features.portal_up')
  entity:give("physicsBody", {
    width = 32,
    height = 32,
    collisionEvent = { name = "portalTouched", properties = { direction = "up" } }
  })
end

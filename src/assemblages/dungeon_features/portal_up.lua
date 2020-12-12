return function(entity)
  entity:give("sprite", 'dungeon_features.portal_up', "onGround")
  entity:give("physicsBody", {
    width = 0.4,
    height = 0.4,
    static = true,
    offsetX = 0.5,
    offsetY = 0.5,
    cornerOrigin = true,
    collisionEvent = { name = "portalTouched", properties = { direction = "up" } }
  })
end

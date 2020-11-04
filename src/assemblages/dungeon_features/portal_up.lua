return function(entity)
  entity:give("sprite", 'dungeon_features.portal_up')
  entity:give("physicsBody", 32, 28,
    nil, nil, false, { name = "portalTouched", properties = { direction = "up" } })
end

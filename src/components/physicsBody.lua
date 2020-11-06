return Concord.component("physicsBody",
  function(self, width, height, tags, targetIgnoreTags, static, collisionEvent, targetTags)
    self.width = width
    self.height = height
    self.tags = tags or {}
    self.targetIgnoreTags = targetIgnoreTags or {}
    self.static = static
    self.collisionEvent = collisionEvent
    self.targetTags = targetTags
  end)


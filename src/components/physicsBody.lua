return Concord.component("physicsBody", function(self, width, height, tags, targetIgnoreTags, static, collisionEvent)
  self.width = width
  self.height = height
  self.tags = tags or {}
  self.targetIgnoreTags = targetIgnoreTags or {}
  self.static = static
  self.collisionEvent = collisionEvent
end)


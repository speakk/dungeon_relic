return Concord.component("physicsBody", function(self, radius, tags, targetIgnoreTags)
  self.radius = radius
  self.tags = tags or {}
  self.targetIgnoreTags = targetIgnoreTags or {}
end)


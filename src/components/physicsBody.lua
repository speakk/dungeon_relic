return Concord.component("physicsBody", function(self, radius, tags, targetIgnoreTags, static)
  self.radius = radius
  self.tags = tags or {}
  self.targetIgnoreTags = targetIgnoreTags or {}
  self.static = static
end)


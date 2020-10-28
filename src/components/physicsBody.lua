return Concord.component("physicsBody", function(self, shapeType, HCproperties, tags, targetIgnoreTags, static)
  self.shapeType = shapeType
  self.HCproperties = HCproperties
  self.tags = tags or {}
  self.targetIgnoreTags = targetIgnoreTags or {}
  self.static = static
end)


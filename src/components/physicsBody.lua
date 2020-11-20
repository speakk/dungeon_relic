return Concord.component("physicsBody",
  function(self, conf)
    self.width = conf.width
    self.height = conf.height
    self.tags = conf.tags or {}
    self.targetIgnoreTags = conf.targetIgnoreTags or {}
    self.static = conf.static
    self.collisionEvent = conf.collisionEvent
    self.targetTags = conf.targetTags
    self.centered = conf.centered
  end)


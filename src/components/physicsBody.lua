return Concord.component("physicsBody",
  function(self, conf)

    -- offsetX, offsetY will be normalized
    -- to center of sprite
    self.offsetX = conf.offsetX or 0.5
    self.offsetY = conf.offsetY or 0.5
    -- width and height will be centered around
    -- entity position + offsetX, offsetY
    self.width = conf.width
    self.height = conf.height
    -- Alternatively one can set pixelWidth/Height
    if conf.width and conf.pixelWidth then
      error("physicsBody can only contain width/height or pixelWidth/pixelHeight, not both")
    end
    self.pixelWidth = conf.pixelWidth
    self.pixelHeight = conf.pixelHeight
    self.tags = conf.tags or {}
    self.targetIgnoreTags = conf.targetIgnoreTags or {}
    self.static = conf.static
    self.collisionEvent = conf.collisionEvent
    self.targetTags = conf.targetTags
    self.centered = conf.centered
  end)


local bitser = require 'libs.bitser'

local component = Concord.component("physicsBody", function(self, conf)

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
  self.responseType = conf.responseType or "slide"
  self.targetTags = conf.targetTags
  self.centered = conf.centered
end)

function component:serialize()
  return {
    offsetX = self.offsetX,
    offsetY = self.offsetY,
    width = self.width,
    height = self.height,
    pixelWidth = self.pixelWidth,
    pixelHeight = self.pixelHeight,
    responseType = self.responseType,
    tags = bitser.dumps(self.tags),
    targetIgnoreTags = bitser.dumps(self.targetIgnoreTags),
    static = self.static,
    collisionEvent = bitser.dumps(self.collisionEvent),
    targetTags = bitser.dumps(self.targetTags),
    centered = self.centered
  }
end

function component:deserialize(data)
  self.offsetX = data.offsetX
  self.offsetY = data.offsetY
  self.width = data.width
  self.height = data.height
  self.pixelWidth = data.pixelWidth
  self.pixelHeight = data.pixelHeight
  self.responseType = data.responseType
  self.tags = bitser.loads(data.tags)
  self.targetIgnoreTags = bitser.loads(data.targetIgnoreTags)
  self.static = data.static
  self.collisionEvent = bitser.loads(data.collisionEvent)
  self.targetTags = bitser.loads(data.targetTags)
  self.centered = data.centered
end

return component

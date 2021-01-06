local bitser = require 'libs.bitser'

local component = Concord.component("animation", function(self, conf)
  self.currentAnimations = conf.currentAnimations or {}
  self.animations = conf.animations
end)

function component:serialize()
  return {
    currentAnimations = bitser.dumps(self.currentAnimations),
    animations = bitser.dumps(self.animations)
  }
end

function component:deserialize(data)
  self.currentAnimations = bitser.loads(data.currentAnimations)
  self.animations = bitser.loads(data.animations)
end

return component

local bitser = require 'libs.bitser'

local component = Concord.component("particle", function(self, systemTypes, offsetX, offsetY)
  self.systemTypes = systemTypes or error("Particle component has to have systemTypes defined")
  self.offsetX = offsetX or 0
  self.offsetY = offsetY or 0
end)

function component:serialize()
  print("serializing particle")
  return {
    systemTypes = bitser.dumps(self.systemTypes),
    offsetX = self.offsetX,
    offsetY = self.offsetY
  }
end

function component:deserialize(data)
  self.systemTypes = bitser.loads(data.systemTypes)
  self.offsetX = data.offsetX
  self.offsetY = data.offsetY
end

return component

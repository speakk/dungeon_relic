local bitser = require 'libs.bitser'

local component = Concord.component("spawner", function(self, delay, assemblageIds, givePosition)
  self.delay = delay or error("No delay given to spawner")
  self.assemblageIds = assemblageIds
  self.givePosition = givePosition
end)

function component:serialize()
  return {
    delay = self.delay,
    assemblageIds = bitser.dump(self.assemblageIds),
    givePosition = self.givePosition
  }
end

function component:deserialize(data)
  self.delay = data.delay
  self.assemblageIds = bitser.loads(data.assemblageIds)
  self.givePosition = data.givePosition
end

return component

local bitser = require 'libs.bitser'

local component = Concord.component("equipmentSlots", function(self, slots)
  self.slots = slots or error("No slots specified for equipmentSlots")
end)

function component:serialize()
  return { slots = bitser.dumps(self.slots) }
end

function component:deserialize(data)
  self.slots = bitser.loads(data.slots)
end

return component

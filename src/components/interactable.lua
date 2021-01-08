local bitser = require 'libs.bitser'

local component = Concord.component("interactable", function(self, tooltip, event, category)
  self.tooltip = tooltip
  self.event = event or error("Interactable must have an event")
  self.category = category or "default"
end)

function component:serialize()
  return {
    tooltip = self.tooltip,
    event = bitser.dumps(self.event),
    category = self.category
  }
end

function component:deserialize(data)
  self.tooltip = data.tooltip
  self.event = bitser.loads(data.event)
  self.category = data.category
end

return component

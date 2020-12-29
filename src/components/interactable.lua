return Concord.component("interactable", function(self, tooltip, event)
  self.tooltip = tooltip
  self.event = event or error("Interactable must have an event")
end)

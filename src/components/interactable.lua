return Concord.component("interactable", function(self, tooltip, event, category)
  self.tooltip = tooltip
  self.event = event or error("Interactable must have an event")
  self.category = category or "default"
end)

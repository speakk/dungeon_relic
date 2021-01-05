return Concord.component("equippable", function(self, slot)
  self.slot = slot or error("Equippable must have slot defined")
end)

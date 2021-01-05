return Concord.component("equippable", function(self, slot, equippedById)
  self.slot = slot or error("Equippable must have slot defined")
  self.equippedById = equippedById
end)

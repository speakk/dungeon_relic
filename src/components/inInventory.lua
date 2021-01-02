return Concord.component("inInventory", function(self, inventoryId)
  self.inventoryId = inventoryId or error("inInventory missing inventoryId")
end)

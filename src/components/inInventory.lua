return Concord.component("inInventory", function(self, entityId)
  self.entityId = entityId or error("inInventory missing inventoryId")
end)

return Concord.component("inventory", function(self, entityId)
  self.entityId = entityId or error("Inventory must have an entity link defined, id was null")
end)

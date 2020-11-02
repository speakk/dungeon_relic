return Concord.component("spawner", function(self, delay, assemblageIds, givePosition)
  self.delay = delay or error("No delay given to spawner")
  self.assemblageIds = assemblageIds
  self.givePosition = givePosition
end)

return Concord.component("selfDestroy", function(self, time)
  self.time = time or error("selfDestroy must have time defined")
end)


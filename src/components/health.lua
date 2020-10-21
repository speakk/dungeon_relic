return Concord.component("health", function(self, maxHealth, value)
  self.maxHealth = maxHealth
  self.value = value or maxHealth
end)


return Concord.component("health", function(self, maxHealth, value, damageCooldown)
  self.maxHealth = maxHealth
  self.value = value or maxHealth
  self.damageCooldown = damageCooldown or 1
end)


return Concord.component("mana", function(self, maxMana, value)
  self.maxMana = maxMana
  self.value = value or maxMana
end)



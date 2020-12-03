return Concord.component("particle", function(self, systemTypes, offsetX, offsetY)
  self.systemTypes = systemTypes or error("Particle component has to have systemTypes defined")
  self.offsetX = offsetX or 0
  self.offsetY = offsetY or 0
end)


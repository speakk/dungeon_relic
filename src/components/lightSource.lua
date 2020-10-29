return Concord.component("lightSource", function(self, radius, r, g, b, a)
  self.radius = radius
  self.r = r or 1
  self.g = g or 1
  self.b = b or 1
  self.a = a or 1
end)


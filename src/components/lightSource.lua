local component = Concord.component("lightSource", function(self, radius, r, g, b, a)
  self.radius = radius
  self.r = r or 1
  self.g = g or 1
  self.b = b or 1
  self.a = a or 1
end)

function component:serialize()
  return {
    radius = self.radius,
    r = self.r,
    g = self.g,
    b = self.b,
    a = self.a,
  }
end

function component:deserialize(data)
  self.radius = data.radius
  self.r = data.r
  self.g = data.g
  self.b = data.b
  self.a = data.a
end

return component

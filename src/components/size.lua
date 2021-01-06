local component = Concord.component("size", function(self, x, y)
  self.vec = Vector(x, y)
end)

function component:serialize()
  local x,y = Vector.split(self.vec)
  return { x = x, y = y }
end

function component:deserialize(data)
  self.vec = Vector(data.x, data.y)
end

return component

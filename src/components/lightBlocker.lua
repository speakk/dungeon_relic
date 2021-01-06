local component = Concord.component("lightBlocker", function(self, width, height)
  self.width = width
  self.height = height
end)

function component:serialize()
  return {
    width = self.width,
    height = self.height
  }
end

function component:deserialize(data)
  self.width = data.width
  self.height = data.height
end

return component

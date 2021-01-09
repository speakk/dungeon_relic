return Concord.component("portal", function(self, direction)
  self.direction = direction or error("Portal needs direction")
end)

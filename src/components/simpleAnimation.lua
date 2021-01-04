return Concord.component("simpleAnimation", function(self, animations)
  for key, animation in pairs(animations) do
    print("Adding key", key, animation)
    self[key] = animation
  end
end)

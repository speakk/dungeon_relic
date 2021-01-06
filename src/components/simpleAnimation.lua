local bitser = require 'libs.bitser'

local component = Concord.component("simpleAnimation", function(self, animations)
  self._originalAnimations = animations
  for key, animation in pairs(animations) do
    self[key] = animation
  end
end)

function component:serialize()
  print("serializing simpleAnimation")
  return { originalAnimations = bitser.dumps(self._originalAnimations) }
end

function component:deserialize(data)
  local originalAnimations = bitser.loads(data.originalAnimations)
  for key, animation in pairs(originalAnimations) do
    self[key] = animation
  end
end

return component

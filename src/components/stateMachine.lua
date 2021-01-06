local component = Concord.component("stateMachine", function(self, stateType) --luacheck: ignore
  self.stateType = stateType
end)

function component:serialize()
  return { stateType = self.stateType }
end

function component:deserialize(data)
  self.stateType = data.stateType
end

return component

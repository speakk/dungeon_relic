local DrawSystem = Concord.system({})

local callBacks = {}

function sortFunction(a, b)
  return a.zIndex < b.zIndex
end

function DrawSystem:draw()
  for _, callBack in ipairs(callBacks) do
    callBack.callBack(callBack.self)
  end
end

function DrawSystem:registerDrawCallback(name, callBack, callBackSelf, zIndex)
  table.insert(callBacks, {
    name = name,
    callBack = callBack,
    self = callBackSelf,
    zIndex = zIndex
  })
  table.stable_sort(callBacks, sortFunction)
end

function DrawSystem:unRegisterDrawCallback(name)
  local callBackMatches = table.filter(callBacks, function(callBack) return callBack.name == name end)
  for callBack in ipairs(callBackMatches) do
    table.remove(callBacks, callBack)
  end
end

return DrawSystem

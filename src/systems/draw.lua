local DrawSystem = Concord.system({})

local callBacks = {}

local function sortFunction(a, b)
  return a.zIndex < b.zIndex
end

function DrawSystem:draw() --luacheck: ignore
  for _, callBack in ipairs(callBacks) do
    callBack.callBack(callBack.self)
  end
end

function DrawSystem:registerDrawCallback(name, callBack, callBackSelf, zIndex) --luacheck: ignore
  table.insert(callBacks, {
    name = name,
    callBack = callBack,
    self = callBackSelf,
    zIndex = zIndex
  })
  table.stable_sort(callBacks, sortFunction)
end

function DrawSystem:unRegisterDrawCallback(name) --luacheck: ignore
  local callBackMatches = table.filter(callBacks, function(callBack) return callBack.name == name end)
  for callBack in ipairs(callBackMatches) do
    table.remove(callBacks, callBack)
  end
end

return DrawSystem

local DrawSystem = Concord.system({})


-- Helper array
local _layerZIndexArray = {
  "preDrawLights",
  "void",
  "ground",
  "groundLevel", -- Level with ground
  "lights",
  "onGround", -- Characters, walls etc go here
  "aboveGround",
  "particles",
  "debugWithCamera",
  "ui",
  "debugNoCamera",
}

local layerZIndexMap = {}
for i, layerName in ipairs(_layerZIndexArray) do
  layerZIndexMap[layerName] = i
end

local function sortFunction(a, b)
  local zIndex1 = layerZIndexMap[a.name]
  local zIndex2 = layerZIndexMap[b.name]
  if not zIndex1 then error("No zIndex1 for: " .. a.name) end
  if not zIndex2 then error("No zIndex2 for: " .. b.name) end
  return zIndex1 < zIndex2
end

function DrawSystem:init()
  self.layers = {}
end

function DrawSystem:draw() --luacheck: ignore
  love.graphics.setColor(1,1,1,1)

  for _, layer in ipairs(self.layers) do

    -- TODO: Add layer shader here

    if layer.followCameraTransform then
      self:getWorld():emit("attachCamera")
    end

    layer.callBack(layer.self)

    if layer.followCameraTransform then
      self:getWorld():emit("detachCamera")
    end
  end
end

function DrawSystem:registerLayer(name, callBack, callBackSelf, followCameraTransform) --luacheck: ignore
  table.insert(self.layers, {
    name = name,
    callBack = callBack,
    self = callBackSelf,
    followCameraTransform = followCameraTransform
  })
  table.stable_sort(self.layers, sortFunction)
end

function DrawSystem:unRegisterLayer(name) --luacheck: ignore
  local layerMatches = table.filter(self.layers, function(layer) return layer.name == name end)
  for layer in ipairs(layerMatches) do
    table.remove(self.layers, layer)
  end
end

return DrawSystem

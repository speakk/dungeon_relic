local DrawSystem = Concord.system({})


-- Helper array
local _layerZIndexArray = {
  "preDrawLights",
  "void",
  "ground",
  "groundLevel", -- Level with ground
  "lights",
  "items",
  "onGround", -- Characters, walls etc go here
  "aboveGround",
  "particles",
  "tooltips",
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
  if not zIndex1 then error("No z-index defined for layer: " .. a.name) end
  if not zIndex2 then error("No z-index defined for layer: " .. b.name) end
  return zIndex1 < zIndex2
end

function DrawSystem:init()
  self.layers = {}
  self.bufferCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
end

local shader = love.graphics.newShader [[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
  float Brightness = 2.2;
  float Contrast = 1.1;
  vec4 AverageLuminance = vec4(0.5, 0.5, 0.5, 1.0);
  vec4 texturecolor = Texel(tex, texture_coords);
  vec4 newColor = mix(texturecolor * Brightness, mix(AverageLuminance, texturecolor, Contrast), 0.5);
  return newColor;
}
]]

function DrawSystem:draw() --luacheck: ignore
  love.graphics.setShader()
  love.graphics.setColor(1,1,1,1)
  for _, layer in ipairs(self.layers) do
    love.graphics.setCanvas(layer.bufferCanvas)
    love.graphics.setColor(1,1,1,1)
    love.graphics.clear(0,0,0,0)

    -- TODO: Add layer shader here

    if layer.followCameraTransform then
      self:getWorld():emit("attachCamera")
    end

    if layer.screenSpaceShader then
      layer.screenSpaceShader.setParams(layer.self)
      love.graphics.setShader(layer.screenSpaceShader.shader)
    end

    layer.callBack(layer.self, layer.bufferCanvas)

    if layer.screenSpaceShader then
      love.graphics.setShader()
    end

    if layer.followCameraTransform then
      self:getWorld():emit("detachCamera")
    end

    love.graphics.setCanvas()
  end


  -- TODO: Change back to "shader" and remove global shaders
  --love.graphics.setShader(shaders.uniformLightShader)
  love.graphics.setCanvas(self.bufferCanvas)
  love.graphics.clear(0,0,0,1)
  love.graphics.setColor(1,1,1,1)
  for _, layer in ipairs(self.layers) do
    if layer.blendModeParams then
      love.graphics.setBlendMode(layer.blendModeParams.blendType, layer.blendModeParams.multiply)
    end
    love.graphics.draw(layer.bufferCanvas)
    if layer.blendModeParams then
      love.graphics.setBlendMode("alpha")
    end
  end
  love.graphics.setCanvas()
  love.graphics.setShader(shader)
  love.graphics.draw(self.bufferCanvas)
  love.graphics.setShader()
end

function DrawSystem:windowResize(w, h)
  self.bufferCanvas = love.graphics.newCanvas(w, h)

  for _, layer in ipairs(self.layers) do
    layer.bufferCanvas = love.graphics.newCanvas(w,h)
  end
end

function DrawSystem:registerLayer(name, callBack, callBackSelf, followCameraTransform, blendModeParams, screenSpaceShader) --luacheck: ignore
  table.insert(self.layers, {
    name = name,
    callBack = callBack,
    self = callBackSelf,
    followCameraTransform = followCameraTransform,
    blendModeParams = blendModeParams,
    screenSpaceShader = screenSpaceShader,
    bufferCanvas = love.graphics.newCanvas(love.graphics.getDimensions()),
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

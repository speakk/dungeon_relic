local Gamestate = require 'libs.hump.gamestate'

local SpriteSystem = Concord.system({ pool = { "sprite", "position" } })

local function compareY(a, b)
  if a.sprite.zIndex ~= b.sprite.zIndex then
    return a.sprite.zIndex < b.sprite.zIndex
  end
  local mediaEntityA = mediaManager:getMediaEntity(a.sprite.spriteId)
  local mediaEntityB = mediaManager:getMediaEntity(b.sprite.spriteId)

  local _, _, _, h1 = mediaEntityA.quads[a.sprite.currentQuadIndex or 1]:getViewport()
  local _, _, _, h2 = mediaEntityB.quads[b.sprite.currentQuadIndex or 1]:getViewport()

  local posA = a.position.vec.y + h1 - mediaEntityA.origin.y * h1
  local posB = b.position.vec.y + h2 - mediaEntityB.origin.y * h2
  return posA < posB
end

    --return texturecolor * color;
shaders = {
  uniformLightShader = love.graphics.newShader [[
  uniform Image lightCanvas;
  uniform vec2 lightCanvasRatio;
  uniform vec2 canvasSize;
  uniform vec2 cameraPos;
  uniform vec2 screenSize;
  uniform float cameraScale;

  uniform vec2 spritePosition;
  uniform vec2 spriteOrigin;

  vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
  {
    vec2 screen_norm = screen_coords / screenSize;
    float screenRatio = screenSize.y / screenSize.x;
    vec2 camPosNorm = cameraPos / screenSize;

    //vec4 lightCanvasColor = Texel(lightCanvas, (screen_coords + cameraPos) / canvasSize); // WORKS WITH CAMERA SCALE 1
    vec4 lightCanvasColor = Texel(lightCanvas, (screen_coords + cameraPos * cameraScale) / canvasSize / cameraScale);
    vec4 texturecolor = Texel(tex, texture_coords);
    return texturecolor * vec4(lightCanvasColor.rgb, 1);
    //return lightCanvasColor;
  }
  ]]
}

local function createRectangle(x, y, w, h, quad, originX, originY)
  return {
    { x, y, quad.x, quad.y, originX, originY },
    { x+w, y, quad.x + quad.w, quad.y, originX, originY },
    { x+w, y+h, quad.x + quad.w, quad.y + quad.h, originX, originY },
    { x, y+h, quad.x, quad.y + quad.h, originX, originY }
  }
end

local function createVertexMap(quadCount)
  local vertexIndices = {}
  for i=1,quadCount do
    local currInd = (i-1)*4 + 1
    table.insert(vertexIndices, currInd)
    table.insert(vertexIndices, currInd+1)
    table.insert(vertexIndices, currInd+2)
    table.insert(vertexIndices, currInd)
    table.insert(vertexIndices, currInd+2)
    table.insert(vertexIndices, currInd+3)
  end

  return vertexIndices
end

function SpriteSystem:cameraUpdated(camera) -- luacheck: ignore
  local x, y = camera:getVisibleCorners() -- works with camera scale 1
  --local x, y = camera:getPosition()
  if shaders.uniformLightShader:hasUniform("cameraPos") then
    shaders.uniformLightShader:send("cameraPos", { x, y })
  end
  if shaders.uniformLightShader:hasUniform("cameraScale") then
    shaders.uniformLightShader:send("cameraScale", camera:getScale())
  end
end

function SpriteSystem:windowResize(w, h) -- luacheck: ignore
  if shaders.uniformLightShader:hasUniform("screenSize") then
    shaders.uniformLightShader:send("screenSize", { w, h })
  end
end

function SpriteSystem:lightsPreDrawn(canvas) --luacheck: ignore
  if shaders.uniformLightShader:hasUniform("lightCanvas") then
    shaders.uniformLightShader:send("lightCanvas", canvas)
  end
  if shaders.uniformLightShader:hasUniform("lightCanvasRatio") then
    shaders.uniformLightShader:send("lightCanvasRatio", {love.graphics.getWidth() / canvas:getWidth(), love.graphics.getHeight() / canvas:getHeight()})
  end
  if shaders.uniformLightShader:hasUniform("canvasSize") then
    shaders.uniformLightShader:send("canvasSize", {canvas:getWidth(), canvas:getHeight()})
  end
end

function SpriteSystem:init()
  self.layers = {}
  self.pool.onEntityAdded = function(_, entity)
    local layerId = entity.sprite.layerId
    self.layers[layerId] = self.layers[layerId] or {}
    table.insert(self.layers[layerId].entities, entity)
  end

  self.pool.onEntityRemoved = function(_, entity)
    local layerId = entity.sprite.layerId
    table.remove_value(self.layers[layerId].entities, entity)
  end
end

function SpriteSystem:setCamera(camera)
  self.camera = camera
end

function SpriteSystem:screenEntitiesUpdated(entities)
  self.screenSpatialGroup = entities
end

local function drawLayer(self, layerId, shaderId)
  if not self.camera then return end

  if shaderId then
    love.graphics.setShader(shaders[shaderId])
  end

  if not self.layers[layerId] then error("Trying to draw into non existing layer: " .. layerId) end
  local inHash = functional.filter(self.layers[layerId].entities, function(entity)
    return functional.contains(self.screenSpatialGroup, entity)
  end)
  local mesh = self.layers[layerId].mesh
  local image = mesh:getTexture()
  local imageW, imageH = image:getDimensions()
  local rects = {}
  local zSorted = table.insertion_sort(inHash, function(a, b) return compareY(a, b) end)
  --local spriteBatch = mediaManager:getSpriteBatch()
  --spriteBatch:clear()
  for _, entity in ipairs(zSorted) do
    local spriteId = entity.sprite.spriteId
    local mediaEntity = mediaManager:getMediaEntity(spriteId)

    local position = entity.position.vec
    local currentQuadIndex = entity.sprite.currentQuadIndex or 1
    local currentQuad = mediaEntity.quads[currentQuadIndex]
    local quadX, quadY, w, h = currentQuad:getViewport()
    local origin = { x = 0, y = 0 }


    if entity.origin then
      origin.x = w * entity.origin.x
      origin.y = h * entity.origin.y
    end

    --print("Adding quad in", layerId, entity.sprite.spriteId)
    --local function createRectangle(x, y, w, h, quad, originX, originY)
    local rect = createRectangle(position.x, position.y, w, h, {
      x = quadX / imageW,
      y = quadY / imageH,
      w = w / imageW,
      h = h / imageH
    }, position.x + origin.x, position.y + origin.y)
    table.insert(rects, rect)
    --currentSpriteBatch:add(currentQuad, position.x, position.y, 0, entity.sprite.scale, entity.sprite.scale, origin.x, origin.y)
    --love.graphics.draw(mediaEntity.atlas, currentQuad, position.x, position.y, 0, entity.sprite.scale, entity.sprite.scale, origin.x, origin.y)
    if Gamestate.current().debug then
      love.graphics.circle('fill', position.x, position.y, 2)
    end

    -- if i == #zSorted or mediaManager:getMediaEntity(zSorted[i+1].sprite.spriteId).spriteBatch ~= currentSpriteBatch then
    --   --print("Drawing", layerId)
    --   love.graphics.draw(currentSpriteBatch)
    -- end
  end

  local vertices = {}
  for _, rect in ipairs(rects) do
    for _, vertex in ipairs(rect) do
      table.insert(vertices, vertex)
    end
  end

  local vertexMap = createVertexMap(#rects)
  mesh:setVertices(vertices)
  mesh:setVertexMap(vertexMap)

  love.graphics.draw(mesh)

  if shaderId then
    love.graphics.setShader()
  end
end

-- local limits = love.graphics.getSystemLimits()
-- local maxTextureSize = limits.texturesize
-- 
-- local function createBatch()
--   local atlas = love.graphics.newCanvas(maxTextureSize, maxTextureSize)
--   return {
--     atlas = atlas,
--     spriteBatch = love.graphics.newSpriteBatch(atlas)
--   }
-- end
-- 
-- local function addSpriteToLayer(layer, spriteId)
--   local mediaEntity = mediaManager.getMediaEntity(spriteId)
--   local batchesSize = #(layer.batches)
--   if batchesSize == 0 then 
--   layer.batches[lastIndex] = layer.batches[lastIndex] or {
--   local lastBatch = layer.batches[#(layer.batches)]
-- 
-- end

local function createDrawFunction(self, layerName, atlasId, shader)
  local atlasImage = mediaManager:getAtlas(atlasId):getImage()
  local mesh = love.graphics.newMesh({
      { "VertexPosition", "float", 2 },
      { "VertexTexCoord", "float", 2 },
      { "origin", "float", 2 },
    }, 200000, "triangles", "dynamic")
  mesh:setTexture(atlasImage)

  self.layers[layerName] = {
    entities = {},
    mesh = mesh
  }
  return function() drawLayer(self, layerName, shader) end
end

function SpriteSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "ground", createDrawFunction(self, "ground", "dynamic"), self, true)
  self:getWorld():emit("registerLayer", "groundLevel", createDrawFunction(self, "groundDecals", "autoLoaded"), self, true)
  self:getWorld():emit("registerLayer", "onGround", createDrawFunction(self, "onGround", "autoLoaded", "uniformLightShader"), self, true)
  self:getWorld():emit("registerLayer", "aboveGround", createDrawFunction(self, "aboveGround", "autoLoaded"), self, true)
end

return SpriteSystem

local Lighter = require 'libs.lighter'

local LightSystem = Concord.system({
  lightSources = { "lightSource", "position"},
  --potentialLightSources = { "lightSource", "position"},
  --potentialLightBlockers = { "lightBlocker", "position"},
  lightBlockers = { "lightBlocker", "position"},
})

function LightSystem:init(_)
  self.lightCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
  self.lighter = Lighter({ litPolygons = true })

  self.lightSources.onEntityAdded = function(_, entity)
    entity.lightSource.light = self.lighter:addLight(
     entity.position.vec.x,
     entity.position.vec.y,
     entity.lightSource.radius,
     entity.lightSource.r,
     entity.lightSource.g,
     entity.lightSource.b,
     entity.lightSource.a
   )
  end

  self.lightSources.onEntityRemoved = function(_, entity)
    self.lighter:removeLight(entity.lightSource.light)
  end

  self.lightBlockers.onEntityAdded = function(_, entity)
    local pos = entity.position.vec
    local w, h = entity.lightBlocker.width, entity.lightBlocker.height
    entity.lightBlocker.blocker = self.lighter:addPolygon({
      pos.x, pos.y,
      pos.x + w, pos.y,
      pos.x + w, pos.y + h,
      pos.x, pos.y + h,
      pos.x, pos.y
    })
  end

  self.lightBlockers.onEntityRemoved = function(_, entity)
    self.lighter:removePolygon(entity.lightBlocker.blocker)
  end
end

function LightSystem:windowResize(width, height)
  self.lightCanvas = love.graphics.newCanvas(width, height)
end

function LightSystem:drawDebugWithCamera()
  --for _, light in ipairs(self.lighter.lights) do
  --  self.lighter:drawVisibilityPolygon(light)
  --end
end

function LightSystem:preDrawLights()
  love.graphics.setCanvas({ self.lightCanvas, stencil = true})
  love.graphics.clear(0.2, 0.2, 0.2)
  love.graphics.setBlendMode("add")
  self.lighter:drawLights()
  love.graphics.setBlendMode("alpha")
  --love.graphics.setColor(0.9, 0.9, 0.9, 0.1)
  --love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
  love.graphics.setCanvas()
  self:getWorld():emit("lightsPreDrawn", self.lightCanvas)
end

function LightSystem:drawLights()
  love.graphics.setBlendMode("multiply", "premultiplied")
  love.graphics.draw(self.lightCanvas)
  love.graphics.setBlendMode("alpha")
end

function LightSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "preDrawLights", LightSystem.preDrawLights, self, false)
  self:getWorld():emit("registerLayer", "lights", LightSystem.drawLights, self, true)
end

function LightSystem:update(dt)

  --lighting.Update()

  -- if self.camera then
  --   local l, t, w, h = self.camera:getVisible()
  --   local onScreenAll = {}
  --   Gamestate.current().spatialHash:each(l, t, w, h, function(entity)
  --     table.insert(onScreenAll, entity)
  --   end)

  --   -- for _, potentialLightSource in ipairs(self.potentialLightSources) do
  --   --   if functional.contains(onScreenAll, potentialLightSource) then
  --   --     -- Remove from onScreenAll to optimize finding it for the next
  --   --     -- potentialLightSource
  --   --     table.remove_value(onScreenAll, potentialLightSource)
  --   --     if not potentialLightSource.lightSourceActive then
  --   --       potentialLightSource:ensure("lightSourceActive")
  --   --     end
  --   --   else
  --   --     potentialLightSource:remove("lightSourceActive")
  --   --   end
  --   -- end
  --   -- for _, potentialLightBlocker in ipairs(self.potentialLightBlockers) do
  --   --   if functional.contains(onScreenAll, potentialLightBlocker) then
  --   --     -- Remove from onScreenAll to optimize finding it for the next
  --   --     -- potentialLightBlocker
  --   --     table.remove_value(onScreenAll, potentialLightBlocker)
  --   --     if not potentialLightBlocker.lightBlockerActive then
  --   --       potentialLightBlocker:give("lightBlockerActive")
  --   --     end
  --   --   else
  --   --     potentialLightBlocker:remove("lightBlockerActive")
  --   --   end
  --   -- end
  -- end
end


function LightSystem:setCamera(camera)
  self.camera = camera
end

function LightSystem:entityMoved(entity)
  if entity.lightSource and entity.lightSource.light then
    self.lighter:updateLight(entity.lightSource.light, Vector.split(entity.position.vec))
  end

  if entity.lightBlocker and entity.lightBlocker.blocker then
  end
end

return LightSystem

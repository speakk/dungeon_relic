local Gamestate = require 'libs.hump.gamestate'
local lighting = require 'libs.Yellows-Lighting-Lib'

local LightSystem = Concord.system({
  lightSources = { "lightSource", "position"},
  --potentialLightSources = { "lightSource", "position"},
  --potentialLightBlockers = { "lightBlocker", "position"},
  lightBlockers = { "lightBlocker", "position"},
})

function LightSystem:init(world)
  self.lightCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
  lighting.Init()

  self.lightSources.onEntityAdded = function(pool, entity)
    entity.lightSource.light = lighting.CreateCircleLight(
      entity.position.vec.x,
      entity.position.vec.y,
      entity.lightSource.radius
    )

    entity.lightSource.light:SetColor(
      entity.lightSource.r,
      entity.lightSource.g,
      entity.lightSource.b,
      entity.lightSource.a
    )

  end

  self.lightSources.onEntityRemoved = function(_, entity)
    lighting.Remove(entity.lightSource.light.id, true)
  end

  self.lightBlockers.onEntityAdded = function(_, entity)
    entity.lightBlocker.blocker = lighting.CreateRectangonalBlocker(
      entity.position.vec.x,
      entity.position.vec.y,
      entity.lightBlocker.width,
      entity.lightBlocker.height
    )
  end

  self.lightBlockers.onEntityRemoved = function(pool, entity)
    entity.lightBlocker.blocker:Remove()
  end
end

function LightSystem:windowResize(width, height)
  self.lightCanvas = love.graphics.newCanvas(width, height)
end

function LightSystem:preDrawLights()
  love.graphics.setCanvas({ self.lightCanvas, stencil = true})
  love.graphics.clear(0.4, 0.4, 0.4)
  lighting.Draw()
  love.graphics.setCanvas()
end

function LightSystem:drawLights()
  love.graphics.setBlendMode("multiply", "premultiplied")
  love.graphics.draw(self.lightCanvas)
  love.graphics.setBlendMode("alpha")
end

function LightSystem:update(_)
  lighting.Update()

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
    entity.lightSource.light:SetPos(Vector.split(entity.position.vec))
  end

  if entity.lightBlocker and entity.lightBlocker.blocker then
    entity.lightBlocker.blocker:SetPos(Vector.split(entity.position.vec))
  end
end

return LightSystem

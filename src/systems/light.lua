local Gamestate = require 'libs.hump.gamestate'
--local light = require 'utils.light'
local Lighter = require 'libs.lighter'

local LightSystem = Concord.system({
  lightSources = { "lightSource", "position"},
  --potentialLightSources = { "lightSource", "position"},
  --potentialLightBlockers = { "lightBlocker", "position"},
  lightBlockers = { "lightBlocker", "position"},
})

local testPolygon = {
  100, 100,
  300, 100,
  300, 300,
  100, 300,
  100, 100
}

local testPolygon2 = {
  500, 500,
  850, 500,
  850, 850,
  500, 850,
  500, 500
}

function LightSystem:init(world)
  self.lightCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
  self.lighter = Lighter()

  self.lightSources.onEntityAdded = function(pool, entity)
    entity.lightSource.light = self.lighter:addLight(
     entity.position.vec.x,
     entity.position.vec.y,
     entity.lightSource.radius,
     entity.lightSource.r,
     entity.lightSource.g,
     entity.lightSource.b,
     entity.lightSource.a
   )
    --entity.lightSource.light = lighting.CreateCircleLight(
    --  entity.position.vec.x,
    --  entity.position.vec.y,
    --  entity.lightSource.radius
    --)

    --entity.lightSource.light:SetColor(
    --  entity.lightSource.r,
    --  entity.lightSource.g,
    --  entity.lightSource.b,
    --  entity.lightSource.a
    --)

  end

  self.lightSources.onEntityRemoved = function(_, entity)
    self.lighter:removeLight(entity.lightSource.light)
    --lighting.Remove(entity.lightSource.light.id, true)
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

    --entity.lightBlocker.blocker = lighting.CreateRectangonalBlocker(
    --  entity.position.vec.x,
    --  entity.position.vec.y,
    --  entity.lightBlocker.width,
    --  entity.lightBlocker.height
    --)
  end

  self.lightBlockers.onEntityRemoved = function(_, entity)
    self.lighter:removePolygon(entity.lightBlocker.blocker)
    --entity.lightBlocker.blocker:Remove()
  end
end

function LightSystem:windowResize(width, height)
  self.lightCanvas = love.graphics.newCanvas(width, height)
end

function LightSystem:preDrawLights()
  love.graphics.setCanvas({ self.lightCanvas, stencil = true})
  love.graphics.clear(0.4, 0.4, 0.4)
  self.lighter:drawLights()
  love.graphics.setCanvas()
end

function LightSystem:drawLights()
  love.graphics.setBlendMode("multiply", "premultiplied")
  love.graphics.draw(self.lightCanvas)
  love.graphics.setBlendMode("alpha")
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
    --entity.lightSource.light:SetPos(Vector.split(entity.position.vec))
  end

  if entity.lightBlocker and entity.lightBlocker.blocker then
    --entity.lightBlocker.blocker:SetPos(Vector.split(entity.position.vec))
  end
end

return LightSystem

local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'

local SpatialHashSystem = Concord.system({ pool = { "position" } })

function SpatialHashSystem:setCamera(camera)
  self.camera = camera
end

function SpatialHashSystem:update()
  if not self.camera then return end

  local l, t, w, h = self.camera:getVisible()

  local screenSpatialGroup = {}
  Gamestate.current().spatialHash:each(l, t, w, h, function(entity)
    table.insert(screenSpatialGroup, entity)
  end)

  self:getWorld():emit("screenEntitiesUpdated", screenSpatialGroup)
end

function SpatialHashSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local w, h
    if entity.sprite then
      local sprite = entity.sprite
      w,h = mediaManager:getMediaEntity(sprite.spriteId).quads[sprite.currentQuadIndex or 1]:getTextureDimensions()
    elseif entity.physicsBody then
      local _, _, physicsWidth, physicsHeight = positionUtil.getPhysicsBodyTransform(entity)
      w, h = physicsWidth, physicsHeight
    else
      local tileSize = Gamestate.current().mapManager.map.tileSize
      w, h = tileSize, tileSize
    end

    local origX = entity.origin and entity.origin.x or 0
    local origY = entity.origin and entity.origin.y or 0

    Gamestate.current().spatialHash:add(
      entity,
      entity.position.vec.x - origX * w,
      entity.position.vec.y - origY * h,
      w,
      h
    )
  end

  self.pool.onEntityRemoved = function(_, entity)
    Gamestate.current().spatialHash:remove(entity)
  end
end

function SpatialHashSystem:entityMoved(entity) -- luacheck: ignore
  Gamestate.current().spatialHash:update(
    entity,
    entity.position.vec.x,
    entity.position.vec.y
  )
end

return SpatialHashSystem

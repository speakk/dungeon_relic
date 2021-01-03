local inGame = require 'states.inGame'
local positionUtil = require 'utils.position'

local SpatialHashSystem = Concord.system({ pool = { "position" }, interactable = { "position", "interactable" } })

function SpatialHashSystem:setCamera(camera)
  self.camera = camera
end

function SpatialHashSystem:update()
  if not self.camera then return end

  local l, t, w, h = self.camera:getVisible()

  local screenSpatialGroup = {}
  inGame.spatialHash.all:each(l, t, w, h, function(entity)
    table.insert(screenSpatialGroup, entity)
  end)

  self:getWorld():emit("screenEntitiesUpdated", screenSpatialGroup)
end

local function getEntityDimensions(entity)
  local w, h
  local _
  if entity.sprite then
    local sprite = entity.sprite
    _, _, w,h = mediaManager:getMediaEntity(sprite.spriteId).quads[sprite:getCurrentQuadIndex()]:getViewport()
  elseif entity.physicsBody then
    local _, _, physicsWidth, physicsHeight = positionUtil.getPhysicsBodyTransform(entity)
    w, h = physicsWidth, physicsHeight
  else
    local tileSize = inGame.mapManager.map.tileSize
    w, h = tileSize, tileSize
  end

  local origX = entity.origin and entity.origin.x or 0
  local origY = entity.origin and entity.origin.y or 0

  return entity.position.vec.x - origX * w, entity.position.vec.y - origY * h, w, h
end

function SpatialHashSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local x, y, w, h = getEntityDimensions(entity)
    inGame.spatialHash.all:add( entity, x, y, w, h)
  end

  self.interactable.onEntityAdded = function(_, entity)
    local x, y, w, h = getEntityDimensions(entity)
    inGame.spatialHash.interactable:add( entity, x, y, w, h)
  end

  self.pool.onEntityRemoved = function(_, entity)
    inGame.spatialHash.all:remove(entity)
  end

  self.interactable.onEntityRemoved = function(_, entity)
    inGame.spatialHash.interactable:remove(entity)
  end
end

function SpatialHashSystem:entityMoved(entity) -- luacheck: ignore
  inGame.spatialHash.all:update(
    entity,
    entity.position.vec.x,
    entity.position.vec.y
  )

  if entity.interactable then
    inGame.spatialHash.interactable:update(
      entity,
      entity.position.vec.x,
      entity.position.vec.y
    )
  end
end

return SpatialHashSystem

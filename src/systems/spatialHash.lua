local Gamestate = require 'libs.hump.gamestate'

local SpatialHashSystem = Concord.system({ pool = { "position" } })

function SpatialHashSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    -- TODO: Re-think "size" component and physicsBody size and how it relates to the spatial hash.
    -- Perhaps just picking the largest bounds would be good. Also, a "size" component doesn't really make
    -- sense, should probably have various kinds of size components for different purposes

    local w, h
    if entity.sprite then
      local sprite = entity.sprite
      w,h = mediaManager:getMediaEntity(sprite.spriteId).quads[sprite.currentQuadIndex or 1]:getTextureDimensions()
    elseif entity.physicsBody then
      w, h = entity.physicsBody.width, entity.physicsBody.height
    else
      local tileSize = Gamestate.current().mapManager.map.tileSize
      w, h = tileSize, tileSize
    end

    Gamestate.current().spatialHash:add(
      entity,
      entity.position.vec.x,
      entity.position.vec.y,
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



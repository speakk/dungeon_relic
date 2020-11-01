local Gamestate = require 'libs.hump.gamestate'

local SpatialHashSystem = Concord.system({ pool = { "position" } })

function SpatialHashSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local size = entity.size and entity.size.vec
    -- TODO: Re-think "size" component and physicsBody size and how it relates to the spatial hash.
    -- Perhaps just picking the largest bounds would be good. Also, a "size" component doesn't really make
    -- sense, should probably have various kinds of size components for different purposes
    if not size and entity.physicsBody then
      size = Vector(entity.physicsBody.width, entity.physicsBody.height)
    end
    if not size then
      size = Vector(
        Gamestate.current().mapManager.map.tileSize,
        Gamestate.current().mapManager.map.tileSize
      )
    end

    Gamestate.current().spatialHash:add(
      entity,
      entity.position.vec.x,
      entity.position.vec.y,
      size.x,
      size.y
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



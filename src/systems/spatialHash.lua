local Gamestate = require 'libs.hump.gamestate'

local SpatialHashSystem = Concord.system({ pool = { "position" } })

function SpatialHashSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local size = entity.size and entity.size.vec
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

function SpatialHashSystem:entityMoved(entity)
  Gamestate.current().spatialHash:update(
    entity,
    entity.position.vec.x,
    entity.position.vec.y
  )
end

return SpatialHashSystem



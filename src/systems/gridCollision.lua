local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'

local GridCollisionSystem = Concord.system({ pool = { "gridCollisionItem", "position" } })

local function setCollisionValue(x, y, value)
  local mapManager = Gamestate.current().mapManager
  mapManager:setCollisionMapValue(
  positionUtil.pixelToGrid(x),
  positionUtil.pixelToGrid(y),
  value)
end

function GridCollisionSystem:init(_)
  self.pool.onEntityAdded = function(_, entity)
    setCollisionValue(entity.position.vec.x, entity.position.vec.y, 1)
  end

  self.pool.onEntityRemoved = function(_, entity)
    setCollisionValue(entity.position.vec.x, entity.position.vec.y, 0)
  end
end

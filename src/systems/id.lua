local Gamestate = require 'libs.hump.gamestate'

local IDSystem = Concord.system({ pool = { 'id' }})

function IDSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    Gamestate.current():setEntityId(entity.id.value, entity)
  end

  self.pool.onEntityRemoved = function(_, entity)
    Gamestate.current():removeEntityId(entity.id.value)
  end
end

return IDSystem

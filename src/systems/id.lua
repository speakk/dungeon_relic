local inGame = require 'states.inGame'

local IDSystem = Concord.system({ pool = { 'id' }})

function IDSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    inGame:setEntityId(entity.id.value, entity)
  end

  self.pool.onEntityRemoved = function(_, entity)
    inGame:removeEntityId(entity.id.value)
  end
end

return IDSystem

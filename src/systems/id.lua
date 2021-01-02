local Gamestate = require 'libs.hump.gamestate'

local IDSystem = Concord.system({ pool = { 'id' }})

function IDSystem:init()
  -- self.pool.onEntityAdded = function(_, entity)
  --   print("onEntityAdded for id")
  --   if not entity.id.value then
  --     local id = Gamestate.current():generateEntityID()
  --     print("ADDING ID", id)
  --     entity.id.value = id
  --   end
  -- end
end

return IDSystem

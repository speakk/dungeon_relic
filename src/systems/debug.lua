local Gamestate = require 'libs.hump.gamestate'

local DebugSystem = Concord.system({})

function DebugSystem:enableDebug() -- luacheck: ignore
  Gamestate.current().debug = true
end

function DebugSystem:disableDebug() -- luacheck: ignore
  Gamestate.current().debug = false
end

function DebugSystem:toggleDebug() -- luacheck: ignore
  Gamestate.current().debug = not Gamestate.current().debug
end

return DebugSystem

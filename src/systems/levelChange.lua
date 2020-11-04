local Gamestate = require 'libs.hump.gamestate'

local LevelChangeSystem = Concord.system({})

function LevelChangeSystem:descendLevel() --luacheck: ignore
  Gamestate.current():descendLevel()
end

function LevelChangeSystem:ascendLevel() --luacheck: ignore
  Gamestate.current():ascendLevel()
end

return LevelChangeSystem

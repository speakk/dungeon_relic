local Gamestate = require 'libs.hump.gamestate'

local LevelChangeSystem = Concord.system({})

function LevelChangeSystem:descendLevel() --luacheck: ignore

  Gamestate.current():descendLevel()
end

return LevelChangeSystem

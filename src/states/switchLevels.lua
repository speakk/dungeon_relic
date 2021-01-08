local Gamestate = require 'libs.hump.gamestate'
local switchLevels = {}

function switchLevels:enter(_, existingState, newLevelNumber, descending) --luacheck: ignore
  local inGame = require 'states.inGame'
  Gamestate.switch(inGame, false, {
    levelNumber = newLevelNumber,
    descending = descending
  })
end

return switchLevels

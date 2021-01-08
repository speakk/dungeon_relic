local Gamestate = require 'libs.hump.gamestate'
local switchLevels = {}


function switchLevels:enter(_, existingState, currentLevelNumber, newLevelNumber) --luacheck: ignore
  local inGame = require 'states.inGame'
  Gamestate.switch(inGame, existingState, currentLevelNumber, newLevelNumber)
end

return switchLevels

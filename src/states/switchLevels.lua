local Gamestate = require 'libs.hump.gamestate'
local switchLevels = {}


function switchLevels:enter(previousState, currentLevelNumber, newLevelNumber) --luacheck: ignore
  local inGame = require 'states.inGame'
  Gamestate.switch(inGame, newLevelNumber)
end

return switchLevels

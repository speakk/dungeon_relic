local Gamestate = require 'libs.hump.gamestate'
local switchLevels = {}

function switchLevels:enter(_, entityIdHead, persistentEntities, newLevelNumber, descending) --luacheck: ignore
  local inGame = require 'states.inGame'
  Gamestate.switch(inGame, false, {
    levelNumber = newLevelNumber,
    persistentEntities = persistentEntities,
    entityIdHead = entityIdHead,
    descending = descending
  })
end

return switchLevels

local inGame = require 'states.inGame'

local LevelChangeSystem = Concord.system({})

function LevelChangeSystem:descendLevel() --luacheck: ignore
  inGame:descendLevel()
end

function LevelChangeSystem:ascendLevel() --luacheck: ignore
  inGame:ascendLevel()
end

return LevelChangeSystem

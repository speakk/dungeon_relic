local bitser = require 'libs.bitser'
local Gamestate = require 'libs.hump.gamestate'

local inGame = require 'states.inGame'
local switchLevels = require 'states.switchLevels'

local quickSaveName = "quickSave.save"

local function saveGame(fileName)
  local inGameData = bitser.dumps(inGame:serialize())
  love.filesystem.write(fileName, inGameData)
  --
  -- local inGameData = inGame:serialize()
  -- print("Serialized", inspect(inGameData))
end

local function loadGame(fileName)
  local data = bitser.loads(love.filesystem.read(fileName))
  Gamestate.switch(inGame, true, {
    data = data
  })
  --inGame:deserialize(bitser.loads(data))
  --Gamestate.switch(switchLevels, data)
end

return {
  quickSave = function()
    saveGame(quickSaveName)
  end,
  quickLoad = function()
    loadGame(quickSaveName)
  end
}

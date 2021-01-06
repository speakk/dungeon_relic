local bitser = require 'libs.bitser'

local inGame = require 'states.inGame'

local quickSaveName = "quickSave.save"

local function saveGame(fileName)
  local inGameData = bitser.dumps(inGame:serialize())
  love.filesystem.write(fileName, inGameData)
  --
  -- local inGameData = inGame:serialize()
  -- print("Serialized", inspect(inGameData))
end

local function loadGame(fileName)
  local data = love.filesystem.read(fileName)
  inGame:deserialize(bitser.loads(data))
end

return {
  quickSave = function()
    saveGame(quickSaveName)
  end,
  quickLoad = function()
    loadGame(quickSaveName)
  end
}

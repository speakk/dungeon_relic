local saveUtils = require 'utils.save'
local inGame = require 'states.inGame'

local keyMap = require 'keymap'
local reverseKeyMap = {}
for action, mappedKey in ipairs(keyMap) do
  reverseKeyMap[mappedKey] = action
end

local InputSystem = Concord.system({})

local function checkInput(keyMapDef)
  local key = keyMap[keyMapDef]
  if key == "mouse1" then
    return love.mouse.isDown(1)
  elseif key == "mouse2" then
    return love.mouse.isDown(2)
  else
    return love.keyboard.isDown(key)
  end
end

function InputSystem:update(dt)
  if checkInput('moveDown') then
    self:getWorld():emit('moveDown')
  end

  if checkInput('moveUp') then
    self:getWorld():emit('moveUp')
  end

  if checkInput('moveRight') then
    self:getWorld():emit('moveRight')
  end

  if checkInput('moveLeft') then
    self:getWorld():emit('moveLeft')
  end

  if checkInput('goBallistic') then
    self:getWorld():emit("playersGoBallistic")
  end

  if checkInput('shoot') then
    self:getWorld():emit('playerShoot')
  end

  -- local shooting = false
  -- local shootingDirection = Vector()

  -- if love.keyboard.isDown('a') then
  --   shooting = true
  --   shootingDirection = shootingDirection + Vector(-1, 0)
  -- end

  -- if love.keyboard.isDown('d') then
  --   shooting = true
  --   shootingDirection = shootingDirection + Vector(1, 0)
  -- end

  -- if love.keyboard.isDown('w') then
  --   shooting = true
  --   shootingDirection = shootingDirection + Vector(0, -1)
  -- end

  -- if love.keyboard.isDown('s') then
  --   shooting = true
  --   shootingDirection = shootingDirection + Vector(0, 1)
  -- end

  -- if shooting then
  --   self:getWorld():emit('playerShoot', shootingDirection.normalized)
  -- end
end

function InputSystem:mouseMoved(x, y)
  local worldX, worldY = inGame.camera:toWorld(x,y)
  self:getWorld():emit("playerLookAt", worldX, worldY)
end

function InputSystem:keyPressed(pressedKey)
  if pressedKey == 't' then
    self:getWorld():emit("toggleDebug")
  end

  if reverseKeyMap[pressedKey] == "interact" then
    self:getWorld():emit('playerInteractIntent')
  end

  if pressedKey == 'c' then
    self:getWorld():emit('playerPickupIntent')
  end

  if pressedKey == 'tab' then
    self:getWorld():emit('showInventory')
  end

  if pressedKey == 'f5' then
    saveUtils.quickSave()
  end

  if pressedKey == 'f8' then
    saveUtils.quickLoad()
  end
end

return InputSystem

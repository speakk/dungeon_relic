local InputSystem = Concord.system({})

function InputSystem:update(dt)
  if love.keyboard.isDown('down') then
    self:getWorld():emit('moveDown')
  end

  if love.keyboard.isDown('up') then
    self:getWorld():emit('moveUp')
  end

  if love.keyboard.isDown('right') then
    self:getWorld():emit('moveRight')
  end

  if love.keyboard.isDown('left') then
    self:getWorld():emit('moveLeft')
  end

  local shooting = false
  local shootingDirection = Vector()

  if love.keyboard.isDown('a') then
    shooting = true
    shootingDirection = shootingDirection + Vector(-1, 0)
  end

  if love.keyboard.isDown('d') then
    shooting = true
    shootingDirection = shootingDirection + Vector(1, 0)
  end

  if love.keyboard.isDown('w') then
    shooting = true
    shootingDirection = shootingDirection + Vector(0, -1)
  end

  if love.keyboard.isDown('s') then
    shooting = true
    shootingDirection = shootingDirection + Vector(0, 1)
  end

  if shooting then
    self:getWorld():emit('playerShoot', shootingDirection.normalized)
  end

  if love.keyboard.isDown('space') then
    self:getWorld():emit('playerInteractIntent')
  end
end

function InputSystem:keyPressed(pressedKey, scancode, isrepeat)
  if pressedKey == 't' then
    self:getWorld():emit("toggleDebug")
  end
end

return InputSystem

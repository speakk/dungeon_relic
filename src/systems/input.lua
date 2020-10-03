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

  if love.keyboard.isDown('space') then
    self:getWorld():emit('shoot')
  end
end

return InputSystem

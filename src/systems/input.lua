local InputSystem = Concord.system({})

function InputSystem:update(dt)
  if love.keyboard.isDown('s') then
    self:getWorld():emit('moveDown')
  end

  if love.keyboard.isDown('w') then
    self:getWorld():emit('moveUp')
  end

  if love.keyboard.isDown('d') then
    self:getWorld():emit('moveRight')
  end

  if love.keyboard.isDown('a') then
    self:getWorld():emit('moveLeft')
  end

  if love.mouse.isDown(1) then
    self:getWorld():emit('shoot')
  end
end

return InputSystem

local ShootSystem = Concord.system({})

function ShootSystem:shoot(sourceEntity, from, direction, bulletTypeSelector, targetIgnoreTags)
  print("Shooting", sourceEntity, from, direction, bulletTypeSelector, ignoreGroups)
  local bulletTypeSelector = bulletTypeSelector or 'bullets.basicBullet'
  local bullet = Concord.entity(self:getWorld()):assemble(ECS.a.getBySelector(bulletTypeSelector))

  bullet.position.vec = from.copy
  bullet.directionIntent.vec = direction.copy
  bullet.physicsBody.targetIgnoreTags = targetIgnoreTags
end

return ShootSystem

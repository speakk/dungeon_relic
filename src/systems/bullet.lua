local BulletSystem = Concord.system({})

function BulletSystem:shoot(sourceEntity, from, direction, bulletTypeSelector, targetIgnoreTags)
  bulletTypeSelector = bulletTypeSelector or 'bullets.basicBullet'
  local bullet = Concord.entity(self:getWorld()):assemble(ECS.a.getBySelector(bulletTypeSelector))

  bullet.position.vec = from.copy
  bullet.directionIntent.vec = direction.copy
  table.append_inplace(bullet.physicsBody.targetIgnoreTags, targetIgnoreTags)
  bullet.physicsBody.collisionEvent = { name = "bulletCollision" }
end

function BulletSystem:bulletCollision(bulletEntity, target)
  self:getWorld():emit("takeDamage", target, bulletEntity.damager.value)

  Concord.entity(self:getWorld()):assemble(ECS.a.getBySelector('particle_emitters.smallDamageHit'))
  :give('position', Vector.split(bulletEntity.position.vec))
  :give('origin', 0.5, 0.5)

  Concord.entity(self:getWorld()):assemble(ECS.a.getBySelector('particle_emitters.bulletHit'))
  :give('position', Vector.split(bulletEntity.position.vec))
  :give('origin', 0.5, 0.5)

  bulletEntity:destroy()
end

return BulletSystem

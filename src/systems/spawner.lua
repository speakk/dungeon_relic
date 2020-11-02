local SpawnerSystem = Concord.system({ pool = { "spawner" } })

function SpawnerSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity.spawner.countDown = entity.spawner.delay
  end
end

function SpawnerSystem:spawnEntity(entity, spawnerEntity)
  if spawnerEntity.spawner.givePosition then
    entity:give("position", Vector.split(spawnerEntity.position.vec))
  end

  self:getWorld():addEntity(entity)
  self:getWorld():emit("entitySpawned", entity, spawnerEntity)
end

function SpawnerSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    local spawner = entity.spawner
    spawner.countDown = spawner.countDown - dt
    if spawner.countDown < 0 then
      local selector = table.pick_random(spawner.assemblageIds)
      local spawnedEntity = Concord.entity():assemble(ECS.a.getBySelector(selector))
      self:spawnEntity(spawnedEntity, entity)
      spawner.countDown = spawner.delay
    end
  end
end

return SpawnerSystem

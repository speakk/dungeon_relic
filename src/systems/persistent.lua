local inGame = require 'states.inGame'

local PersistentSystem = Concord.system({ pool = { "persistent" } })

local relationComponents = {
  inventory = "entityId",
  inInventory = "entityId",
  equippable = "equippedById"
}

local function createPersistentList(entity, list, world)
  list = list or {}
  if functional.contains(list, entity) then return end
  table.insert(list, entity)

  -- If entity has relations, follow those and save all
  for key, relationProperty in pairs(relationComponents) do
    if entity[key] then
      local id = entity[key][relationProperty]
      if id then
        local relationEntity = inGame:getEntity(id)
        createPersistentList(relationEntity, list, world)
      end
    end
  end

  -- Check if any other entity in the world points to this entity
  for _, otherEntity in ipairs(world.__entities) do
    for key, relationProperty in pairs(relationComponents) do
      if otherEntity[key] then
        local id = otherEntity[key][relationProperty]
        if id == entity.id.value then
          --local relationEntity = inGame:getEntity(id)
          createPersistentList(otherEntity, list, world)
        end
      end
    end
  end

  return list
end

function PersistentSystem:persistEntities()
  self:getWorld():__flush()

  local allPersistent = {}
  for _, entity in ipairs(self.pool) do
    for _, persistent in ipairs(createPersistentList(entity, nil, self:getWorld())) do
      table.insert(allPersistent, persistent)
    end
  end

  local unique = set(allPersistent)
  local serializedEntities = functional.map(unique:values_readonly(), function(entity)
    return entity:serialize()
  end)

  inGame.persistentEntities = serializedEntities
end

return PersistentSystem

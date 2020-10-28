local Gamestate = require 'libs.hump.gamestate'

local PhysicsBodySystem = Concord.system({ pool = {"physicsBody", "position"} })

function PhysicsBodySystem:init()
  self.pool.onEntityAdded = function(_, entity)
    Gamestate.current().bumpWorld:add(entity, entity.position.vec.x, entity.position.vec.y, entity.physicsBody.width, entity.physicsBody.height)
  end

  self.pool.onEntityRemoved = function(_, entity)
    Gamestate.current().bumpWorld:remove(entity)
  end
end

local function containsAnyInTable(a, b)
  for _, aItem in ipairs(a) do
    for _, bItem in ipairs(b) do
      if aItem == bItem then
        return true
      end
    end
  end
end

local function handleCollisionEvent(world, source, target)
  local event = source.physicsBody.collisionEvent
  if event then
    world:emit(event.name, source, target)
  end
end

function PhysicsBodySystem:update(dt)
  local bumpWorld = Gamestate.current().bumpWorld
  for _, entity in ipairs(self.pool) do
    if entity.position then
      local actualX, actualY, collisions, _ = bumpWorld:move(entity, entity.position.vec.x, entity.position.vec.y,
      function(item, other)
        local containsIgnore = containsAnyInTable(other.physicsBody.tags, item.physicsBody.targetIgnoreTags)
        or containsAnyInTable(item.physicsBody.tags, other.physicsBody.targetIgnoreTags)

        if not containsIgnore then
          return "slide"
        else
          return false
        end
      end)

      if not entity.physicsBody.static then
        entity.position.vec.x = actualX
        entity.position.vec.y = actualY
      end

      for _, collision in ipairs(collisions) do
        handleCollisionEvent(self:getWorld(), collision.item, collision.other)
        handleCollisionEvent(self:getWorld(), collision.other, collision.item)
      end
    end
  end
end

return PhysicsBodySystem

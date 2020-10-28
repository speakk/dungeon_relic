HC = require 'libs.HC'

local PhysicsBodySystem = Concord.system({ pool = {"physicsBody"} })

local getHCProperties = {
  circle = function(entity)
    return entity.position.vec.x, entity.position.vec.y, entity.physicsBody.HCproperties.radius
  end,
  polygon = function(entity)
    return unpack(entity.physicsBody.HCproperties.polygon)
  end
}

function PhysicsBodySystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity.physicsBody.body = HC[entity.physicsBody.shapeType](getHCProperties[entity.physicsBody.shapeType](entity))
    entity.physicsBody.body.parent = entity
  end

  self.pool.onEntityRemoved = function(_, entity)
    HC.remove(entity.physicsBody.body)
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

function PhysicsBodySystem:drawDebugWithCamera()
  for _, entity in ipairs(self.pool) do
    entity.physicsBody.body:draw("fill")
  end
end
      
function PhysicsBodySystem:update(dt)
  for _, entity in ipairs(self.pool) do
    if entity.position then
      entity.physicsBody.body:moveTo(Vector.split(entity.position.vec))
      for otherShape, delta in pairs(HC.collisions(entity.physicsBody.body)) do
        local containsIgnore = containsAnyInTable(otherShape.parent.physicsBody.tags, entity.physicsBody.targetIgnoreTags) or containsAnyInTable(entity.physicsBody.tags, otherShape.parent.physicsBody.targetIgnoreTags)

        if not containsIgnore then
          handleCollisionEvent(self:getWorld(), entity, otherShape.parent)
          handleCollisionEvent(self:getWorld(), otherShape.parent, entity)
          if not entity.physicsBody.static then
            entity.position.vec = entity.position.vec + Vector(delta.x, delta.y)
          end
        end
      end
    end
  end
end

return PhysicsBodySystem

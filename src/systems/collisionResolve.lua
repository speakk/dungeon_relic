HC = require 'libs.HC'

local CollisionResolveSystem = Concord.system({ pool = {"physicsBody", "position"}})

function CollisionResolveSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    entity.physicsBody.body = HC.circle(entity.position.vec.x, entity.position.vec.y, entity.physicsBody.radius)
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
      
function CollisionResolveSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.physicsBody.body:moveTo(Vector.split(entity.position.vec))
    for otherShape, delta in pairs(HC.collisions(entity.physicsBody.body)) do
      local containsIgnore = containsAnyInTable(entity.physicsBody.targetIgnoreTags, otherShape.parent.physicsBody.tags) or containsAnyInTable(entity.physicsBody.tags, otherShape.parent.physicsBody.targetIgnoreTags)

      if not containsIgnore then
        entity.position.vec = entity.position.vec + Vector(delta.x, delta.y)
      end
    end
  end
end

return CollisionResolveSystem

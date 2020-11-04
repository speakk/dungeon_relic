local Gamestate = require 'libs.hump.gamestate'

local PhysicsBodySystem = Concord.system({ pool = {"physicsBody", "position", "physicsBodyActive"}, potential = {"physicsBody", "position"} })

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
    world:emit(event.name, source, target, event.properties)
  end
end

function PhysicsBodySystem:setCamera(camera)
  self.camera = camera
end

function PhysicsBodySystem:drawDebugWithCamera() --luacheck: ignore
  for _, entity in ipairs(self.pool) do
    love.graphics.setColor(1,1,0)
    local pos = entity.position.vec
    local w = entity.physicsBody.width
    local h = entity.physicsBody.height
    local polygon = {
      pos.x, pos.y,
      pos.x + w, pos.y,
      pos.x + w, pos.y + h,
      pos.x, pos.y + h,
    }
    love.graphics.polygon("line", polygon)
    love.graphics.setColor(1,1,1)
  end
end


function PhysicsBodySystem:markOutOfScreenInactive()
  if self.camera then
    local l, t, w, h = self.camera:getVisible()
    local onScreenAll = {}
    Gamestate.current().spatialHash:each(l, t, w, h, function(entity)
      table.insert(onScreenAll, entity)
    end)

    for _, entity in ipairs(self.potential) do
      if functional.contains(onScreenAll, entity) then
        -- Remove from onScreenAll to optimize finding it for the next
        -- entity
        table.remove_value(onScreenAll, entity)
        if not entity.physicsBodyActive then
          entity:ensure("physicsBodyActive")
        end
      else
        entity:remove("physicsBodyActive")
      end
    end
  end
end

function PhysicsBodySystem:update(dt)
  self:markOutOfScreenInactive()

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

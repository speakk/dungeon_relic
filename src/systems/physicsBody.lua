local Gamestate = require 'libs.hump.gamestate'
local positionUtil = require 'utils.position'

local PhysicsBodySystem = Concord.system({ pool = {"physicsBody", "position", "physicsBodyActive"}, potential = {"physicsBody", "position"} })

local function getOriginOffset(entity)
  if entity.physicsBody.cornerOrigin then
    return 0, 0
  end

  local w,h = entity.physicsBody.width, entity.physicsBody.height
  if entity.sprite then
    local mediaEntity = mediaManager:getMediaEntity(entity.sprite.spriteId)
    return mediaEntity.origin.x * w, mediaEntity.origin.y * h
  end
  return w/2, h/2
end

local function getCenteredLocation(entity)
  local pos = entity.position.vec
  local offX, offY = getOriginOffset(entity)
  return pos.x - offX, pos.y - offY
end

function PhysicsBodySystem:init()
  self.pool.onEntityAdded = function(_, entity)
    --local x, y = entity.physicsBody.centered and getCenteredLocation(entity) or entity.position.vec.x, entity.position.vec.y
    local transformX, transformY, w, h = positionUtil.getPhysicsBodyTransform(entity)
    local targetX, targetY = Vector.split(entity.position.vec - Vector(transformX, transformY))

    Gamestate.current().bumpWorld:add(entity, targetX, targetY, w, h)
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
    if event.targetTags then
      if not target.physicsBody.tags or not containsAnyInTable(event.targetTags, target.physicsBody.tags) then
        return
      end
    end
    world:emit(event.name, source, target, event.properties)
  end
end

function PhysicsBodySystem:setCamera(camera)
  self.camera = camera
end

function PhysicsBodySystem:drawDebugWithCamera() --luacheck: ignore
  for _, entity in ipairs(self.pool) do
    love.graphics.setColor(1,1,0)
    local offsetX, offsetY, w, h = positionUtil.getPhysicsBodyTransform(entity)
    local pos = entity.position.vec
    -- local w = entity.physicsBody.width
    -- local h = entity.physicsBody.height
    love.graphics.rectangle("line", pos.x - offsetX, pos.y - offsetY, w, h)
    love.graphics.setColor(1,1,1)
  end

  local bumpWorld = Gamestate.current().bumpWorld
  local items, _ = bumpWorld:getItems()
  love.graphics.setColor(0,1,0)
  for _, item in ipairs(items) do
    local x,y,w,h = bumpWorld:getRect(item)
    love.graphics.rectangle('line', x, y, w, h)
  end
  love.graphics.setColor(1,1,1)
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
end

function PhysicsBodySystem:entityMoved(entity)
  if not entity.physicsBody then return end
  local bumpWorld = Gamestate.current().bumpWorld
  if not bumpWorld:hasItem(entity) then return end
  if entity.position and not entity.physicsBody.static then
    --local targetX, targetY = getCenteredLocation(entity)
    local transformX, transformY = positionUtil.getPhysicsBodyTransform(entity)
    local targetX, targetY = Vector.split(entity.position.vec + Vector(transformX, transformY))
    local physicsX, physicsY, collisions, _ = bumpWorld:move(entity, targetX, targetY,
    function(item, other)
      local containsIgnore = containsAnyInTable(other.physicsBody.tags, item.physicsBody.targetIgnoreTags)
      or containsAnyInTable(item.physicsBody.tags, other.physicsBody.targetIgnoreTags)
      if containsIgnore then
        return false
      end

      local hasRequired = true
      if item.physicsBody.targetTags then
        hasRequired = containsAnyInTable(item.physicsBody.targetTags, other.physicsBody.tags)
      end

      if hasRequired then
        return "slide"
      else
        return false
      end
    end)

    if not entity.physicsBody.static then
      self:getWorld():emit("entityMovedByPhysics", entity, physicsX, physicsY)
      --local offsetX, offsetY = getOriginOffset(entity)
      --entity.position.vec.x - w/2, entity.position.vec.y - h/2
      --entity.position.vec.x = actualX + offsetX
      --entity.position.vec.y = actualY + offsetY
    end

    for _, collision in ipairs(collisions) do
      handleCollisionEvent(self:getWorld(), collision.item, collision.other)
      handleCollisionEvent(self:getWorld(), collision.other, collision.item)
    end
  end
end

--self:getWorld():emit("entityMovedByPhysics", entity, physicsX, physicsY)
function PhysicsBodySystem:entityMovedByPhysics(entity, physicsX, physicsY)
  --local actualX, actualY = -physicsToActual
  --local offsetX, offsetY = getOriginOffset(entity)
  --entity.position.vec.x - w/2, entity.position.vec.y - h/2
  --entity.position.vec.x = actualX + offsetX
  local transformX, transformY = positionUtil.getPhysicsBodyTransform(entity)
  print("transformX, transformY", transformX, transformY)
  local targetX, targetY = Vector.split(Vector(physicsX, physicsY) - Vector(transformX, transformY))
  entity.position.vec = Vector(targetX, targetY)
end

return PhysicsBodySystem

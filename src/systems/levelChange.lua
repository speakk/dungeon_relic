local inGame = require 'states.inGame'

local LevelChangeSystem = Concord.system({ players = { "playerControlled" }, portals = { "portal", "position" }})

function LevelChangeSystem:descendLevel() --luacheck: ignore
  inGame:descendLevel()
end

function LevelChangeSystem:ascendLevel() --luacheck: ignore
  inGame:ascendLevel()
end

function LevelChangeSystem:levelLoaded(descending)
  for _, entity in ipairs(self.players) do
    local position
    if descending then
      position = functional.find_match(self.portals, function(portalEntity)
        return portalEntity.portal.direction == "up"
      end).position.vec
    else
      position = functional.find_match(self.portals, function(portalEntity)
        return portalEntity.portal.direction == "down"
      end).position.vec
    end
    position = position + Vector(32,32)
    entity:give("position", Vector.split(position))
    entity.position.oldPosition = position

    -- TODO: Clean this up properly, shouldn't update bumpWorld by hand here

    local bumpWorld = inGame.bumpWorld
    bumpWorld:update(entity, Vector.split(entity.position.vec))
    self:getWorld():emit("entityMoved", entity, entity.position.vec)
  end
end

return LevelChangeSystem

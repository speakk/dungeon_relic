local Gamestate = require 'libs.hump.gamestate'

local positionUtils = require 'utils.position'

local PathFindingSystem = Concord.system({ pool = { "pathFind", "position", "directionIntent" } })

function PathFindingSystem:update()
  for _, entity in ipairs(self.pool) do
    if not entity.pathFind.currentPath then
      local targetPosition = entity.pathFind.targetPosition
      local entityX, entityY = Vector.unpack(entity.position.vec)
      local path = Gamestate.current().mapManager.getPath(
        entityX,
        entityY,
        targetPosition.x,
        targetPosition.y
      )

      entity.pathFind.currentPath = path
      entity.pathFind.currentIndex = 1
    end

    if entity.pathFind.currentPath then
      local currentPath = entity.pathFind.currentPath
      local nextNodePosition = currentPath[entity.pathFind.currentIndex]
      local nextPixelPositionX, nextPixelPositionY = positionUtils.gridToPixels(nextNodePosition.x, nextNodePosition.y)
      local directionIntent = entity.position.vec - Vector(nextPixelPositionX, nextPixelPositionY)
      entity.directionIntent.vec = directionIntent.normalized

      --local currentPath = entity.currentPath[entity.pathFind.currentIndex].x

      if entity.pathFind.currentIndex < #(entity.pathFind.currentPath) and
        entity.currentPath[entity.pathFind.currentIndex].x then
        entity.pathFind.currentIndex = entity.pathFind.currentIndex + 1
      else
        entity.pathFind.finished = true
        self.world:emit("targetReached", entity)
      end
    end
  end
end

return PathFindingSystem

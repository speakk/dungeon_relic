local shash = require 'libs.shash'
local Timer = require 'libs.hump.timer'
local bump = require 'libs.bump'

local MapManager = require 'mapManager'

local game = {}

local TESTING = true

function game:enter()
  self.world = Concord.world()
  self.world:addSystems(
    ECS.s.input,
    ECS.s.playerControlled,
    ECS.s.aiControlled,
    ECS.s.bullet,
    ECS.s.movement,
    ECS.s.physicsBody,
    ECS.s.spatialHash,
    ECS.s.gridCollision,
    ECS.s.health,
    ECS.s.death,
    ECS.s.particle,
    ECS.s.selfDestroy,
    ECS.s.camera,
    ECS.s.sprite,
    ECS.s.draw
  )

  local hashCellSize = 256
  self.spatialHash = shash.new(hashCellSize)
  print("HASH?", self.spatialHash)

  self.bumpWorld = bump.newWorld(64)

  self.world:emit('systemsLoaded')


  self.mapManager = MapManager()

  self.mapManager:setMap(MapManager.generateMap(), self.world)

  self.world:emit('mapChange', self.mapManager:getMap())


  if TESTING then
    self.world:emit('initTest')

    -- Make a couple test entities.
    local entity = Concord.entity(self.world):assemble(ECS.a.getBySelector('characters.player'))

    for i=1,300 do
      local entity2 = Concord.entity(self.world):assemble(ECS.a.getBySelector('characters.monsterA'))
      entity2.position.vec = Vector(love.math.random(1000), love.math.random(1000))
    end
  end
end

function game:leave()
  self.world:clear()
end

function game:update(dt)
  Timer.update(dt)
  self.world:emit("clearDirectionIntent", dt)
  self.world:emit("update", dt)
end

function game:resize(width, height)
  self.world:emit('windowResize', width, height)
end

function game:draw()
  self.world:emit("attachCamera")
  self.world:emit("draw")
  self.world:emit("drawDebugWithCamera")
  self.world:emit("detachCamera")
end

return game

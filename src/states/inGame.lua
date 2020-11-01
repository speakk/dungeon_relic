local Gamestate = require 'libs.hump.gamestate'
local shash = require 'libs.shash'
local Timer = require 'libs.hump.timer'
local bump = require 'libs.bump'
local Gamera = require 'libs.gamera'

local switchLevels = require 'states.switchLevels'
local MapManager = require 'mapManager'

local game = {}

local TESTING = true

function game:enter(_, level)
  self.currentLevelNumber = level or 1

  self.world = Concord.world()
  self.world:addSystems(
    ECS.s.input,
    ECS.s.debug,
    ECS.s.playerControlled,
    ECS.s.aiControlled,
    ECS.s.bullet,
    ECS.s.movement,
    ECS.s.physicsBody,
    ECS.s.levelChange,
    ECS.s.portal,
    ECS.s.spatialHash,
    ECS.s.gridCollision,
    ECS.s.light,
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
  local camera = Gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  self.world:emit("setCamera", camera)

  self.mapManager = MapManager()

  self.mapManager:setMap(MapManager.generateMap(self.currentLevelNumber), self.world)

  self.world:emit('mapChange', self.mapManager:getMap())

  if TESTING then
    self.world:emit('initTest')

    -- Make a couple test entities.
    local entity = Concord.entity(self.world):assemble(ECS.a.getBySelector('characters.player'))
    entity:give("position", 300, 450)
    entity:give("lightSource", 200, 1, 0.2, 0.2, 0.5)

    local portalEntity = Concord.entity(self.world):assemble(ECS.a.getBySelector('dungeon_features.portal'))
    portalEntity:give("position", 450, 450)

    --for i=1,1 do
    --  local entity2 = Concord.entity(self.world):assemble(ECS.a.getBySelector('characters.monsterA'))
    --  entity2.position.vec = Vector(love.math.random(1000), love.math.random(1000))
    --  entity2:give("lightSource", love.math.random(10, 100), love.math.random(0.6, 1), love.math.random(0.6, 1), love.math.random(0.6, 1))
    --  entity2:give("lightSourceActive")
    --end
  end
end

function game:leave()
  self.world:emit("systemsCleanUp")
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

function game:descendLevel()
  local newLevelNumber = self.currentLevelNumber + 1
  print("newLevelNumber", newLevelNumber)
  Gamestate.switch(switchLevels, self.currentLevelNumber, newLevelNumber)
end

function game:draw()
  self.world:emit("attachCamera")
  self.world:emit("draw")
  self.world:emit("drawLights")
  if self.debug then self.world:emit("drawDebugWithCamera") end
  self.world:emit("detachCamera")
  if self.debug then self.world:emit("drawDebug") end
end

function game:keypressed(pressedKey, scancode, isrepeat)
  self.world:emit('keyPressed', pressedKey, scancode, isrepeat)
end

return game

local Gamestate = require 'libs.hump.gamestate'
local shash = require 'libs.shash'
local Timer = require 'libs.hump.timer'
local bump = require 'libs.bump'
local flux = require 'libs.flux'
local Gamera = require 'libs.gamera'

local switchLevels = require 'states.switchLevels'
local MapManager = require 'mapManager'

local game = {}

local TESTING = true

-- TODO: Debug spawn global
world = nil
  -- TODO END: Debug spawn global

function game:enter(_, level)
  self.originalSeed, _ = love.math.getRandomSeed()
  local previousLevel = self.currentLevelNumber or 1
  self.currentLevelNumber = level or 1
  love.math.setRandomSeed(self.currentLevelNumber + self.originalSeed)

  self.world = Concord.world()

  -- TODO: Debug spawn global
  world = self.world
  -- TODO END: Debug spawn global

  print("Adding systems")
  self.world:addSystems(
    ECS.s.input,
    ECS.s.debug,
    ECS.s.playerControlled,
    ECS.s.aiControlled,
    ECS.s.stateMachine,
    ECS.s.bullet,
    ECS.s.monster,
    ECS.s.movement,
    ECS.s.physicsBody,
    ECS.s.levelChange,
    -- Dungeon features ->
    ECS.s.portal,
    ECS.s.spawner,
    -- Dungeon features END
    ECS.s.spatialHash,
    ECS.s.gridCollision,
    ECS.s.interactable,
    ECS.s.checkEntityMoved,
    ECS.s.animation,
    ECS.s.light,
    ECS.s.dropShadow,
    ECS.s.health,
    ECS.s.death,
    ECS.s.particle,
    ECS.s.selfDestroy,
    ECS.s.camera,
    ECS.s.sprite,
    ECS.s.draw,
    ECS.s.ui
  )
  print("Systems added")

  local hashCellSize = 256
  self.spatialHash = {
    all = shash.new(hashCellSize),
    interactable = shash.new(hashCellSize)
  }
  --shash.new(hashCellSize)
  --print("HASH?", self.spatialHash)

  self.bumpWorld = bump.newWorld(64)

  self.world:emit('systemsLoaded')
  local camera = Gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  self.world:emit("setCamera", camera)

  self.mapManager = MapManager()

  self.mapManager:setMap(MapManager.generateMap(self.currentLevelNumber, self.currentLevelNumber >= previousLevel), self.world)

  self.world:emit('mapChange', self.mapManager:getMap())

  if TESTING then
    self.world:emit('initTest')
  end
end

function game:leave()
  self.world:emit("systemsCleanUp")
  self.world:clear()
end

function game:update(dt)
  Timer.update(dt)
  self.world:emit("clearDirectionIntent", dt)
  self.world:emit("preUpdate", dt)
  flux.update(dt)
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

function game:ascendLevel()
  local newLevelNumber = self.currentLevelNumber - 1
  print("newLevelNumber", newLevelNumber)
  Gamestate.switch(switchLevels, self.currentLevelNumber, newLevelNumber)
end

function game:draw()
  self.world:emit("draw")
  -- love.graphics.setColor(1,1,1,1)
  -- self.world:emit("attachCamera")
  -- self.world:emit("draw")
  -- self.world:emit("preDrawLights")
  -- if self.debug then self.world:emit("drawDebugWithCamera") end
  -- self.world:emit("drawParticles")
  -- self.world:emit("detachCamera")
  -- self.world:emit("drawLights")
  -- self.world:emit("drawUI")
  -- if self.debug then self.world:emit("drawDebug") end
end


-- TODO: TEMP: DEBUG func to spawn entity
function spawn(assemblageId, x, y)
  local entity = Concord.entity(world):assemble(ECS.a.getBySelector(assemblageId))
  entity:give("position", x*32, y*32)
end

function game:keypressed(pressedKey, scancode, isrepeat)
  self.world:emit('keyPressed', pressedKey, scancode, isrepeat)
end

return game

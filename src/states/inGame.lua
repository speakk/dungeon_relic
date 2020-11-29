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
  self.originalSeed, _ = love.math.getRandomSeed()
  local previousLevel = self.currentLevelNumber or 1
  self.currentLevelNumber = level or 1
  love.math.setRandomSeed(self.currentLevelNumber + self.originalSeed)

  self.world = Concord.world()
  print("Adding systems")
  self.world:addSystems(
    ECS.s.input,
    ECS.s.debug,
    ECS.s.playerControlled,
    ECS.s.aiControlled,
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
    ECS.s.checkEntityMoved,
    ECS.s.animation,
    ECS.s.light,
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
  self.spatialHash = shash.new(hashCellSize)
  print("HASH?", self.spatialHash)

  self.bumpWorld = bump.newWorld(64)

  self.world:emit('systemsLoaded')
  local camera = Gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  self.world:emit("setCamera", camera)

  self.mapManager = MapManager()

  self.mapManager:setMap(MapManager.generateMap(self.currentLevelNumber, self.currentLevelNumber >= previousLevel), self.world)

  self.world:emit('mapChange', self.mapManager:getMap())

  if TESTING then
    self.world:emit('initTest')

    local map = self.mapManager.map

    -- Make a couple test entities.
    --local player = Concord.entity(self.world):assemble(ECS.a.getBySelector('characters.player'))

    local function randomEmptySpot(tiles)
      local emptySpots = {}

      for y=1,#tiles do
        for x=1, #tiles[y] do
          if tiles[y][x] == 0 then
            table.insert(emptySpots, { x = x, y =y })
          end
        end
      end

      local spot = table.pick_random(emptySpots)
      if not spot then return #tiles/2,#tiles/2 end
      return spot.x, spot.y
    end

    --local randomEmptyX, randomEmptyY = randomEmptySpot(self.mapManager:getCollisionMap())
    --player:give("position", randomEmptyX*map.tileSize, randomEmptyY*map.tileSize)

    for i=1,10 do
      local randomEmptyX, randomEmptyY = randomEmptySpot(self.mapManager:getCollisionMap())
      local ent = Concord.entity(self.world)
      ent:give("sprite", "lamps.lamp1")
      ent:give("position", randomEmptyX*map.tileSize, randomEmptyY*map.tileSize)
      --ent:give("lightSource", 400, 1, love.math.random(0.5, 1), love.math.random(0.5, 1), love.math.random(0.5, 1))
      if love.math.random() > 0.5 then
        ent:give("lightSource", 400, 1, 0.6, 0.8)
      else
        ent:give("lightSource", 400, 0.7, 1, 0.8)
      end
    end

    -- if self.currentLevelNumber > 1 then
    --   local ascendEntity = Concord.entity(self.world):assemble(ECS.a.getBySelector('dungeon_features.portal_up'))
    --   ascendEntity:give("position", Vector.split(player.position.vec + Vector(64, 0)))
    -- end

    --Concord.entity(self.world)
    --:give("position", 100, 450)
    ----:give("lightSource", 200, 0.6, 1.0, 0.6, 1.0)

    --Concord.entity(self.world)
    --:give("position", 600, 700)
    ----:give("lightSource", 200, 1.0, 1.0, 0.6, 1.0)

    --randomEmptyX, randomEmptyY = randomEmptySpot(self.mapManager:getCollisionMap())
    --local spawnerEntity = Concord.entity(self.world):assemble(ECS.a.getBySelector('dungeon_features.spawner'))
    --spawnerEntity:give("position", randomEmptyX*map.tileSize, randomEmptyY*map.tileSize)
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
  love.graphics.setColor(1,1,1,1)
  self.world:emit("attachCamera")
  self.world:emit("draw")
  self.world:emit("preDrawLights")
  if self.debug then self.world:emit("drawDebugWithCamera") end
  self.world:emit("detachCamera")
  self.world:emit("drawLights")
  self.world:emit("drawUI")
  if self.debug then self.world:emit("drawDebug") end
end

function game:keypressed(pressedKey, scancode, isrepeat)
  self.world:emit('keyPressed', pressedKey, scancode, isrepeat)
end

return game

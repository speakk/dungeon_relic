local inGame = require 'states.inGame'
local flux = require 'libs.flux'
local Timer = require 'libs.hump.timer'
local StateMachineSystem = Concord.system({ pool = { "stateMachine" } })

local stateTypes = {
  basicAi = function(entity)
    return {
      defaultState = "idle",
      states = {
        idle = {
          enter = function()
            entity.sprite.currentQuadIndex = 1
          end,
          update = function(_, dt)
            local x, y = Vector.split(entity.position.vec)
            local range = 200
            local target = nil
            inGame.spatialHash.all:each(x - range/2, y - range/2, range, range, function(possibleTarget)
              if possibleTarget:has("playerControlled") then
                target = possibleTarget
              end
            end)

            if target then
              entity.stateMachine.target = target
              return "attackPrepare"
            end
          end
        },
        attackPrepare = {
          enter = function()
            --entity:give("aiControlled")
            entity.stateMachine.attackDone = false
            local sprite = entity.sprite
            sprite.currentQuadIndex = 5
            flux.to(sprite, 0.5, { currentQuadIndex = 7 })
            :oncomplete(function() sprite.currentQuadIndex = 8 end)
            :oncomplete(function() Timer.after(0.5, function() entity.stateMachine.attackPrepared = true end) end)
            --entity.animation.currentAnimations = { "attack" }
          end,
          update = function(_, dt)
            if entity.stateMachine.attackPrepared then
              entity.stateMachine.attackPrepared = false
              return "attack"
            end
          end
        },
        attack = {
          enter = function()
            entity.stateMachine.attackDone = false
            local direction = (entity.stateMachine.target.position.vec - entity.position.vec).normalized
            entity.directionIntent.vec = direction

            local maxSpeed = 200
            entity.speed.value = 0

            flux.to(entity.speed, 0.6, { value = maxSpeed })
            :ease('backin')
            :oncomplete(function()
              entity.stateMachine.attackDone = true
              entity.speed.value = 0
              entity.velocity.vec.x = 0
              entity.velocity.vec.y = 0
              entity.directionIntent.vec.x = 0
              entity.directionIntent.vec.y = 0
            end)
          end,
          update = function()
            if entity.stateMachine.attackDone then
              entity.stateMachine.attackDone = false
              entity.stateMachine.attackPrepared = false
              return "idle"
            end
          end
        }
      }
    }
  end,
  player = function(entity)
    return {
      defaultState = "idle",
      states = {
        idle = {
          enter = function()
            entity.animation.currentAnimations = { "idle" }
          end
        },
        run = {
          enter = function()
            if entity.directionIntent.vec.length < 0.1 then
              return "idle"
            end
            entity.animation.currentAnimations = { "run" }
          end,
          update = function()
            if entity.directionIntent.vec.length < 0.1 then
              return "idle"
            end
          end
        }
      }
    }
  end
}

local eventsToStates = {
  { stateType = "player", from = { "entityMoved" }, to = "run" }
}

for _, eventToState in ipairs(eventsToStates) do
  for _, from in ipairs(eventToState.from) do
    StateMachineSystem[from] = function(_, entity, ...)
      if entity.stateMachine and entity.stateMachine.stateType == eventToState.stateType then
        entity.stateMachine.machine:set_state(eventToState.to, ...)
      end
    end
  end
end

function StateMachineSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local machineType = stateTypes[entity.stateMachine.stateType](entity)
    entity.stateMachine.machine = state_machine:new(machineType.states, machineType.defaultState)
    entity.stateMachine.machine:set_state(machineType.defaultState)
  end

  self.pool.onEntityRemoved = function (_, entity)
    entity.stateMachine.machine = nil
  end
end

function StateMachineSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.stateMachine.machine:update(dt)
  end
end

return StateMachineSystem

local inGame = require 'states.inGame'
local flux = require 'libs.flux'
local Timer = require 'libs.hump.timer'
local StateMachineSystem = Concord.system({ pool = { "stateMachine" } })

local stateTypes = {
  flopper = function(entity, world)
    return {
      defaultState = "idle",
      states = {
        idle = {
          enter = function()
            entity.sprite.currentQuadIndex = 1
            entity.animation.currentAnimations = { "idle" }
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
              return "attack"
            end
          end
        },
        attack = {
          enter = function()
            entity.sprite.currentQuadIndex = 1
            entity.animation.currentAnimations = { "run" }
          end,
          update = function(_, dt)
            local direction = (entity.stateMachine.target.position.vec - entity.position.vec).normalized
            entity.directionIntent.vec = direction
            entity.speed.value = 100
          end
        }
      }
    }
  end,
  basicAi = function(entity, world)
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
            world:emit("monsterPrepareAttack")
            entity.stateMachine.attackDone = false
            local sprite = entity.sprite
            sprite.currentQuadIndex = 5
            entity.stateMachine.tween = flux.to(sprite, 0.5, { currentQuadIndex = 7 })
            :oncomplete(function() sprite.currentQuadIndex = 8 end)
            :oncomplete(function() Timer.after(0.5, function()
              if entity.stateMachine then
                entity.stateMachine.attackPrepared = true
              end
            end) end)
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

            local maxSpeed = 300
            entity.speed.value = 0

            entity.stateMachine.tween = flux.to(entity.speed, 0.6, { value = maxSpeed })
            :ease('circout')
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

            -- if entity.stateMachine.animation then
            --   entity.stateMachine.animation:stop()
            -- end

            -- local anim = { from = 4, to = 17, duration = 1 }
            -- local function startAnim()
            --   entity.sprite.currentQuadIndex = anim.from
            --   local tween = flux.to(entity.sprite, anim.duration, { currentQuadIndex = anim.to })
            --   :oncomplete(startAnim)
            --   return tween
            -- end

            --entity.stateMachine.animation = startAnim()
            entity.animation.currentAnimations = { "run" }
          end,
          update = function()
            if entity.directionIntent.vec.length < 0.1 then
              return "idle"
            end
          end
        },
        playerGoBallistic = {
          enter = function()
            entity.stateMachine.machine:_get_state().blocking = true
            entity.stateMachine.ballisticTimeout = 1
            entity.animation.currentAnimations = { "ballistic" }
            entity:remove("friction")
            entity:give("damager", 100)
            entity:give("physicalImmunity")

            local lookX, lookY = entity.lookAt.x, entity.lookAt.y
            local speed = 40
            local direction = (Vector(lookX, lookY) - entity.position.vec).normalized
            entity.directionIntent.vec = direction * speed
          end,
          update = function(self, dt)
            entity.stateMachine.ballisticTimeout = entity.stateMachine.ballisticTimeout - dt
            if entity.stateMachine.ballisticTimeout <= 0 then
              entity.stateMachine.machine:_get_state().blocking = false
              return "idle"
            end
            -- TODO: Rotation
          end,
          exit = function()
            entity:give("friction")
            entity:remove("damager")
            entity:remove("physicalImmunity")
          end
        }
      }
    }
  end
}

--local eventsToStates = {
--  { stateType = "player", from = { "entityMoved" }, to = "run" }
--}

local eventsToStates = {
  { stateType = "player", from = { "entityMoved" }, to = "run" },
  { stateType = "player", from = { "playerGoBallistic" }, to = "playerGoBallistic"}
}

for _, eventToState in ipairs(eventsToStates) do
  for _, from in ipairs(eventToState.from) do
    StateMachineSystem[from] = function(_, entity, ...)
      if not entity then error("Event from eventToState must have entity as first argument") end

      if entity.stateMachine and entity.stateMachine.stateType == eventToState.stateType then
        --print("TO", eventToState.to, entity.stateMachine.machine:_get
        if entity.stateMachine.machine.current_state ~= eventToState.to then
          if not entity.stateMachine.machine:_get_state().blocking then
            entity.stateMachine.machine:set_state(eventToState.to, ...)
          end
        end
      end
    end
  end
end

function StateMachineSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local machineType = stateTypes[entity.stateMachine.stateType](entity, self:getWorld())
    entity.stateMachine.machine = state_machine:new(machineType.states, machineType.defaultState)
    entity.stateMachine.machine:set_state(machineType.defaultState)
  end
end

function StateMachineSystem:removeStateMachineComponent(entity)
  if entity.stateMachine then
    if entity.stateMachine.tween then
      entity.stateMachine.tween:stop()
    end
    entity:remove("stateMachine")
  end
end

function StateMachineSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.stateMachine.machine:update(dt)
  end
end

return StateMachineSystem

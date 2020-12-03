local StateMachineSystem = Concord.system({ pool = { "stateMachine" } })

local stateTypes = {
  basicAi = function(entity)
    return {
      defaultState = "idle",
      states = {
        idle = {
          enter = function()
            print("basicAi idle enter")
          end,
          update = function(dt)
            print("Updating idle")
          end
        },
        move = {}
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
  end
end

function StateMachineSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    entity.stateMachine.machine:update(dt)
  end
end

return StateMachineSystem

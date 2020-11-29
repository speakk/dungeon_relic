local AnimationSystem = Concord.system({ pool = { "animation" }})

function AnimationSystem:init()
  self.pool.onEntityAdded = function(_, entity)
    local animationC = entity.animation
    for _, currentAnimationKey in ipairs(animationC.currentAnimations) do
      local animation = animationC.animations[currentAnimationKey]
      for _, property in ipairs(animation.properties) do
        property.currentValueIndex = 1
        if property.durations then
          property.countDown = property.durations[1]
        end
      end
    end
  end
end

function AnimationSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    local animationC = entity.animation
    for _, currentAnimationKey in ipairs(animationC.currentAnimations) do
      local animation = animationC.animations[currentAnimationKey]
      for _, property in ipairs(animation.properties) do
        if property.durations then
          if property.countDown <= 0 and not property.done then
            property.currentValueIndex = property.currentValueIndex + 1
            if property.currentValueIndex > #(property.values) then
              if property.runOnce then
                property.done = true
                property.currentValueIndex = #(property.values)
              else
                property.currentValueIndex = 1
              end
            end

            property.countDown = property.durations[property.currentValueIndex]
          end

          property.countDown = property.countDown - dt
        end


        entity[property.componentName][property.propertyName] = property.values[property.currentValueIndex]
      end
    end
  end
end

return AnimationSystem

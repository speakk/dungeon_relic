return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("directionIntent")
  entity:give("speed", 0)
  entity:give("damager", 20)
  entity:give("health", 50, nil, 0.1)
  entity:give("sprite", 'characters.flopper', "onGround")
  entity:give("stateMachine", "flopper")

  entity:give("physicsBody", {
    width = 0.7,
    height = 0.2,
    offsetY = 0.9,
    tags = { "monster" },
    collisionEvent = { name = "monsterCollision", targetTags = { "player" } }
  })

  entity:give("simpleAnimation", {
    death = {
      from = 9,
      to = 18,
      duration = 1.5
    }
  })

  entity:give("animation", {
    currentAnimations = { "run" },
    animations = {
      idle = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = functional.generate(4, function(_) return 0.2 end),
            values = functional.generate(4, function(i) return i + 18 end)
          }
        }
      },
      run = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = functional.generate(8, function(_) return 0.05 end),
            values = functional.generate(8, function(i) return i end)
          }
        }
      }
    }
  })
end



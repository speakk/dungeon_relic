return function(entity)
  entity:assemble(ECS.a.characters.character, 700, 700)
  entity:give("playerControlled")
  entity:give("speed", 35)
  entity:give("stateMachine", "player")
  entity:give("sprite", 'characters.player5', "onGround")
  --entity:give("lightSource", 250, 1, 0.8, 0.4, 1.0)
  entity:give("cameraTarget")
  entity:give("mana", 100)
  entity:give("physicsBody", { width = 0.6, height = 0.2, offsetX=0.5, offsetY=0.9, tags = { "player" } })

  entity:give("animation", {
    currentAnimations = { "idle" },
    animations = {
      idle = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = {0.5, 0.2},
            values = { 1, 1 },
          }
        }
      },
      run = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = { 0.1, 0.1, 0.1 },
            values = { 1, 2, 3 },
          }
        }
      }
    }
  })
end


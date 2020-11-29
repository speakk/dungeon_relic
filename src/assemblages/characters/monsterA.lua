return function(entity, x, y)
  entity:assemble(ECS.a.characters.character, x, y)
  entity:give("aiControlled")
  entity:give("speed", 20)
  entity:give("damager", 20)
  entity:give("health", 30)
  entity:give("sprite", 'characters.monster_B-sheet')

  entity:give("physicsBody", {
    width = 1,
    height = 1,
    centered = true,
    tags = { "monster" },
    collisionEvent = { name = "monsterCollision", targetTags = { "player" } }
  })

  entity:give("animation", {
    currentAnimations = { "run" },
    animations = {
      idle = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            values = { 1 },
          }
        }
      },
      run = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = { 0.2, 0.2, 0.3, 0.2 },
            values = { 1, 2, 3, 4 },
          }
        }
      }
    }
  })
end


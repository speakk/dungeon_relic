return function(entity)
  entity:assemble(ECS.a.characters.character, 700, 700)
  entity:give("playerControlled")
  entity:give("displayName", "player")
  entity:give("persistent")
  entity:give("directionIntent")
  entity:give("clearDirectionIntent")
  entity:give("interacter")
  entity:give("equipmentSlots", {
    "headArmor",
    "rightHandArmor",
    "rightHandWeapon",
    "torso",
    "leftHandArmor",
    "leftHandWeapon",
    "rightLegArmor",
    "leftLegArmor"
  })
  entity:give("speed", 200)
  entity:give("origin", 0.5, 0.8)
  entity:give("stateMachine", "player")
  entity:give("sprite", 'characters.player7', "onGround")
  entity:give("lightSource", 400, 1, 0.8, 0.5, 1.0)
  entity:give("cameraTarget")
  entity:give("mana", 100)
  entity:give("physicsBody", { width = 0.6, height = 0.2, offsetX=0.5, offsetY=1.0, tags = { "player" } })

  entity:give("animation", {
    currentAnimations = { "idle" },
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
            durations = functional.generate(13, function(_) return 0.05 end),
            values = functional.generate(13, function(i) return i end)
          }
        }
      }
    }
  })
end


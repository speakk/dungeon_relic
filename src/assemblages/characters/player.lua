return function(entity)
  entity:assemble(ECS.a.characters.character, 700, 700)
  entity:give("playerControlled")
  entity:give("displayName", "player")
  entity:give("friction")
  entity:give("persistent")
  entity:give("directionIntent")
  entity:give("lookAt")
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
  entity:give("speed", 800)
  entity:give("origin", 0.5, 0.8)
  entity:give("stateMachine", "player")
  entity:give("sprite", 'characters.player', "onGround")
  entity:give("lightSource", 400, 1, 0.8, 0.5, 1.0)
  entity:give("cameraTarget")
  entity:give("mana", 100)
  entity:give("physicsBody", { width = 0.6, height = 0.2, offsetX=0.5, offsetY=1.0, tags = { "player" }, responseType = "bounce" })

  entity:give("animation", {
    currentAnimations = { "idle" },
    animations = {
      idle = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = functional.generate(4, function(_) return 0.13 end),
            values = functional.generate(4, function(i) return i + 8 end)
          }
        }
      },
      run = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            durations = functional.generate(8, function(_) return 0.1 end),
            values = functional.generate(8, function(i) return i end)
          }
        }
      },
      ballistic = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            values = { 13 }
          }
        }
      }
    }
  })
end


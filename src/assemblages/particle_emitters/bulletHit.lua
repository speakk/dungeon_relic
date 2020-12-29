return function(entity)
  --entity:give("particle", { "small_damage_hit" })
  entity:give('sprite', 'decals.bullethit', "onGround")
  entity:give('selfDestroy', 10)
  entity:give('origin', 0.5, 0.5)
  entity:give("animation", {
    currentAnimations = { "boom1" },
    animations = {
      boom1 = {
        properties = {
          {
            componentName = "sprite",
            propertyName = "currentQuadIndex",
            runOnce = true,
            durations = {0.05, 0.05, 0.05},
            values = { 1, 2, 3 },
          }
        }
      }
    }
  })
end


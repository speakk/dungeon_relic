return function(entity)
  entity:give("particle", { "small_damage_hit" })
  entity:give('selfDestroy', 200)
end


return function(entity)
  entity:give("sprite", "lamps.lamp2", "onGround")
  entity:give("particle", { "magic_torch" }, 15, 12)
  entity:give("lightSource", 200, 1, 0.6, 0.4)
end
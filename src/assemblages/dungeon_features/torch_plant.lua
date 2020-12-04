return function(entity)
  entity:give("sprite", "lamps.lamp1")
  entity:give("particle", { "magic_torch" }, 10, 10)
  if love.math.random() > 0.5 then
    entity:give("lightSource", 400, 1, 0.6, 0.8)
  else
    entity:give("lightSource", 400, 0.7, 1, 0.8)
  end
end

return function(entity, x, y)
  entity:give("position", x, y)
  entity:give("size", 10, 10) -- TODO: do not hard code this
  entity:give("speed", 70)
  entity:give("damager", 40)
  entity:give("velocity")
  entity:give("selfDestroy", 500)
  entity:give("directionIntent")
  entity:give("lightSource", 300, 0.8, 0.8, 1.0, 1.0)
  entity:give("origin", 0.5, 0.5)
  entity:give("physicsBody", {
    centered = true,
    width = 1,
    height = 1,
    tags = { "bullet" },
    targetIgnoreTags = { "bullet" }
  })
  entity:give("sprite", "bullets.basicBullet", "onGround")
end


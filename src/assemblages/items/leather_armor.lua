return function(entity)
  entity:give("item")
  entity:give("displayName", "Leather Armor")
  entity:give("sprite", "armor.leather", "items")
  entity:give("equippable", "torso")
  entity:give("origin", 0.5, 0.5)
end


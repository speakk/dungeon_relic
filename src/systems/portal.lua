local PortalSystem = Concord.system({})

function PortalSystem:portalTouched(portal, entityWhichTouched) -- luacheck: ignore
  -- HOLY MOLY TIME TO CHANGE LEVELS, SWEET
  --
  -- TODO: Add some particle swirls and a Timer before descending.
  -- (aka a make shift level transition animation)
  self:getWorld():emit("descendLevel")
end

return PortalSystem

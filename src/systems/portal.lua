local PortalSystem = Concord.system({})

function PortalSystem:portalTouched(portal, entityWhichTouched, props) -- luacheck: ignore
  if entityWhichTouched.playerControlled then
    -- HOLY MOLY TIME TO CHANGE LEVELS, SWEET
    --
    -- TODO: Add some particle swirls and a Timer before descending.
    -- (aka a make shift level transition animation)
    if props.direction == "down" then
      self:getWorld():emit("descendLevel")
    else
      self:getWorld():emit("ascendLevel")
    end
  end
end

return PortalSystem

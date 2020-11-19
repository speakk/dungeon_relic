local CheckEntityMovedSystem = Concord.system({ pool = { "position" }})

function CheckEntityMovedSystem:preUpdate(_)
  for _, entity in ipairs(self.pool) do
    entity.position.oldPosition = entity.position.vec.copy
  end
end

function CheckEntityMovedSystem:update(_)
  for _, entity in ipairs(self.pool) do
    if entity.position.oldPosition ~= entity.position.vec then
      self:getWorld():emit("entityMoved", entity, entity.position.oldPosition)
    end
  end
end

return CheckEntityMovedSystem

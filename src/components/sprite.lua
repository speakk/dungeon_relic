return Concord.component("sprite", function(self, spriteId, zIndex, scale)
  self.spriteId = spriteId
  self.zIndex = zIndex or 0
  self.scale = scale or 1
end)

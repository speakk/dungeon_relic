return Concord.component("sprite", function(self, spriteId, layerId, zIndex, scale)
  self.spriteId = spriteId
  self.zIndex = zIndex or 0
  self.layerId = layerId or error("Sprite must have layerId")
  self.scale = scale or 1
  self.currentQuadIndex = 1
end)

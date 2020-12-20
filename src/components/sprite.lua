return Concord.component("sprite", function(self, spriteId, layerId, conf)
  conf = conf or {}
  self.spriteId = spriteId or error("Sprite must have spriteId")
  self.layerId = layerId or error("Sprite must have layerId")
  self.zIndex = conf.zIndex or 0
  self.scale = conf.scale or 1

  self.currentQuadIndex = 1
end)

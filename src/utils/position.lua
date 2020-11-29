local Gamestate = require 'libs.hump.gamestate'

return {
  positionToString = function(x, y)
    return x + '|' + y
  end,
  gridToPixels = function(x, y)
    local tileSize = Gamestate.current().mapManager.map.tileSize
    return x*tileSize, y*tileSize
  end,
  getPhysicsBodyTransform = function(entity)
    local body = entity.physicsBody
    if entity.sprite then
      local mediaEntity = mediaManager:getMediaEntity(entity.sprite.spriteId)
      local quad = mediaEntity.quads[entity.sprite.currentQuadIndex or 1]
      local _, _, quadW, quadH = quad:getViewport()
      local w = quadW * body.width
      local h = quadH * body.height
      local originX, originY = mediaEntity.origin.x, mediaEntity.origin.y
      print("origin: ", originX, originY)
      print(w, h, quadW, quadH, body.offsetX, body.offsetY, body.width, body.height)
      local x = (quadW * body.offsetX - quadW) * originX
      local y = (quadH * body.offsetY - quadH) * originY
      return x, y, w, h
    end

    -- TODO: Replace 32 with tilesize
    return 0, 0, body.pixelWidth or 32, body.pixelHeight or 32
  end
}

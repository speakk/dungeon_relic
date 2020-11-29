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

      print("originX, originY, quadW, quadH", originX, originY, quadW, quadH)
      local originXpx = -originX * quadW
      local centerX = originXpx + body.offsetX * quadW
      local x = centerX - w/2
      local originYpx = -originY * quadW
      local centerY = originYpx + body.offsetY * quadW
      local y = centerY - w/2



      --local x = -(w * body.offsetX - w) * body.offsetX
      --x = x - originX * quadW
      --local y = -(h * body.offsetY - h) * body.offsetY
      --y = y - originY * quadH
      return x, y, w, h
    end

    -- TODO: Replace 32 with tilesize
    return 0, 0, body.pixelWidth or 32, body.pixelHeight or 32
  end
}

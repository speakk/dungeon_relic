local Gamestate = require 'libs.hump.gamestate'
local memoize = require 'libs.memoize'

local getTransform = memoize(function(body, sprite)
  if sprite then
    local mediaEntity = mediaManager:getMediaEntity(sprite.spriteId)
    local quad = mediaEntity.quads[sprite.currentQuadIndex or 1]
    local _, _, quadW, quadH = quad:getViewport()
    local w = quadW * body.width
    local h = quadH * body.height

    local originX, originY = mediaEntity.origin.x, mediaEntity.origin.y

    local originXpx = -originX * quadW
    local centerX = originXpx + body.offsetX * quadW
    local x = centerX - w/2

    local originYpx = -originY * quadW
    local centerY = originYpx + body.offsetY * quadW
    local y = centerY - w/2

    return x, y, w, h
  end
  return 0, 0, body.pixelWidth or 32, body.pixelHeight or 32
end)

return {
  positionToString = function(x, y)
    return x + '|' + y
  end,
  gridToPixels = function(x, y)
    local tileSize = Gamestate.current().mapManager.map.tileSize
    return x*tileSize, y*tileSize
  end,
  getPhysicsBodyTransform = function(entity)
    return getTransform(entity.physicsBody, entity.sprite)
    -- local body = entity.physicsBody
    -- if entity.sprite then
    --   local mediaEntity = mediaManager:getMediaEntity(entity.sprite.spriteId)
    --   local quad = mediaEntity.quads[entity.sprite.currentQuadIndex or 1]
    --   local _, _, quadW, quadH = quad:getViewport()
    --   local w = quadW * body.width
    --   local h = quadH * body.height

    --   local originX, originY = mediaEntity.origin.x, mediaEntity.origin.y

    --   local originXpx = -originX * quadW
    --   local centerX = originXpx + body.offsetX * quadW
    --   local x = centerX - w/2

    --   local originYpx = -originY * quadW
    --   local centerY = originYpx + body.offsetY * quadW
    --   local y = centerY - w/2

    --   return x, y, w, h
    -- end

    -- -- TODO: Replace 32 with tilesize
    -- return 0, 0, body.pixelWidth or 32, body.pixelHeight or 32
  end
}

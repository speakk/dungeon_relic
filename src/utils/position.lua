local settings = require 'settings'
local memoize = require 'libs.memoize'

local getTransform = memoize(function(body, entity)
  local sprite = entity.sprite
  if sprite then
    local mediaEntity = mediaManager:getMediaEntity(sprite.spriteId)
    local quad = mediaEntity.quads[sprite:getCurrentQuadIndex()]
    local _, _, quadW, quadH = quad:getViewport()
    local w = quadW * body.width
    local h = quadH * body.height

    local originX = entity.origin and entity.origin.x or 0
    local originY = entity.origin and entity.origin.y or 0

    local originXpx = -originX * quadW
    local centerX = originXpx + body.offsetX * quadW
    local x = centerX - w/2

    local originYpx = -originY * quadW
    local centerY = originYpx + body.offsetY * quadW
    local y = centerY - w/2

    return x - settings.spritePadding, y - settings.spritePadding, w, h
  end
  return 0, 0, body.pixelWidth or 32, body.pixelHeight or 32
end)

return {
  positionToString = function(x, y)
    return x + '|' + y
  end,
  gridToPixels = function(x, y)
    local tileSize = settings.tileSize
    return x*tileSize, y*tileSize
  end,
  getPhysicsBodyTransform = function(entity)
    return getTransform(entity.physicsBody, entity)
  end
}

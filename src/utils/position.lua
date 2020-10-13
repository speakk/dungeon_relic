local Gamestate = require 'libs.hump.gamestate'

return {
  positionToString = function(x, y)
    return x + '|' + y
  end,
  gridToPixels = function(x, y)
    local tileSize = Gamestate.current().mapManager.map.tileSize
    return x*tileSize, y*tileSize
  end
}

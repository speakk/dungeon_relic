return {
  generateTestMap = function()
    local widthTiles = 50
    local heightTiles = 50

    return {
      tileSize = 64,
      size = { x = widthTiles, y = heightTiles },
      layers = {
        {
          name = "background",
          tiles = functional.generate_2d(widthTiles, heightTiles, function(x, y)
            return {
              spriteId = 'tiles.ground_1',
              x = x,
              y = y
            }
          end)
        }
      }
    }
  end
}

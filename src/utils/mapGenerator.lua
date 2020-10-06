return {
  generateTestMap = function()
    local widthTiles = 50
    local heightTiles = 50

    local tileSize = 64

    return {
      tileSize = tileSize,
      size = { x = widthTiles, y = heightTiles },
      layers = {
        {
          name = 'background',
          tiles = functional.generate_2d(widthTiles, heightTiles, function(x, y)
            return {
              spriteId = 'tiles.ground_1',
              x = x - 1,
              y = y - 1
            }
          end)
        }
      },
      -- Generate some test walls
      -- TODO: Walls should most likely be as a separate layer, with the 
      entities = functional.generate_2d(20, 5, function(x, y)
        return {
          components = {
            {
              name = 'sprite',
              properties = { 'tiles.wall_1' }
            },
            {
              name = 'position',
              properties = { (x - 1) * tileSize, (y - 1) * tileSize * 2 }
            }
          }
        }
      end)
    }
  end
}

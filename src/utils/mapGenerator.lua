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
              x = x,
              y = y
            }
          end)
        },
        {
          name = 'walls',
          isZSorted = true,
          rows = {
            {
              tiles = functional.generate(20, function(i)
                print("i is", i)
                return {
                  spriteId = 'tiles.wall_1',
                  x = i,
                  y = 0
                }
              end)
            },
            {
              tiles = functional.generate(20, function(i)
                return {
                  spriteId = 'tiles.wall_1',
                  x = i+5,
                  y = 0
                }
              end)
            }
          }
        }
      },
      -- Generate some test walls
      -- TODO: Walls should most likely be as a separate layer, with the 
      entities = functional.generate(20, function(i)
        return {
            components = {
              {
                name = 'sprite',
                properties = { 'tiles.wall_1' }
              },
              {
                name = 'position',
                properties = { 6*tileSize, 4*tileSize }
              }
            }
          }
        end)
      }
    end
  }

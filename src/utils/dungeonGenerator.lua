local dungeonGenerator = {}

local tileTypes = {
  floor = 'floor',
  wall = 'wall'
}

-- width has to be divisible by cellWidth
-- height has to be divisible by cellHeight
function dungeonGenerator.generateDungeon(width, height, cellWidth, cellHeight, conf)
  conf = conf or {}
  if math.fmod(width, cellWidth) ~= 0 or math.fmod(height, cellHeight) ~= 0 then
    error("width and height have to be divisible by cellWidth and cellHeight respectively")
  end

  local cellsX = width / cellWidth
  local cellsY = height / cellHeight

  local cells = functional.generate(cellsY, function()
    return functional.generate(cellsX, function()
      return {}
    end)
  end)

  local roomsMax = conf.roomsMax or #cells
  local roomsMin = conf.roomsMin or 2

  local roomAmount = love.math.random(roomsMin, roomsMax)
  print("roomAmount", roomAmount)

  local availableCells = {}
  for y=1,cellsY do for x=1,cellsX do table.insert(availableCells, { x = x, y = y }) end end

  local rooms = {}
  local roomWidthMin = conf.roomWidthMin or 2
  local roomHeightMin = conf.roomHeightMin or 2

  for _=1,roomAmount do
    local cell = table.pick_random(availableCells)
    table.remove_value(availableCells, cell)
    local x, y = cell.x, cell.y
    local w = love.math.random(roomWidthMin, cellWidth)
    local h = love.math.random(roomHeightMin, cellHeight)
    local room = { cellX = x, cellY = y, w = w, h = h, x = (x-1)*cellWidth + 1, y = (y-1)*cellHeight + 1 }
    table.insert(rooms, room)
    cells[y][x] = { cellType = "room", metaData = room }
  end


  -- Generate final map object to return
  local tiles = functional.generate(height, function()
    return functional.generate(width, function()
      return tileTypes.wall
    end)
  end)

  print("cellsY, cellsX", cellsY, cellsX)
  for cellY=1,cellsY do
    for cellX=1,cellsX do
      local cellData = cells[cellY][cellX]
      if cellData.cellType == "room" then
        local roomInfo = cellData.metaData
        for y=0,roomInfo.h-1 do
          for x=0,roomInfo.w-1 do
            --print("Setting tile", cellY, cellX, cellY*(cellHeight-1) + y, cellX*(cellWidth-1) + x)
            --tiles[(cellY-1)*(cellHeight-1) + 1 + y][(cellX-1)*(cellWidth-1) + 1 + x] = tileTypes.floor
            local yIndex = (cellY-1)*cellHeight + 1 + y
            local xIndex = (cellX-1)*cellWidth + 1 + x
            print("yIndex, xIndex", yIndex, xIndex, "cellY, cellX", cellY, cellX)
            tiles[yIndex][xIndex] = tileTypes.floor
          end
        end
      else
        print("Not a room", cellY, cellX)
      end
    end
  end

  return {
    tiles = tiles,
    rooms = rooms
  }
end

return dungeonGenerator

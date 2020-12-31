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

  -- Surround map with walls thickness of outerPadding
  local outerPadding = conf.outerPadding or 1

  local roomAmount = love.math.random(roomsMin, roomsMax)
  print("roomAmount", roomAmount)

  local availableCells = {}
  for y=1,cellsY do for x=1,cellsX do table.insert(availableCells, { x = x, y = y }) end end

  local rooms = {}
  local roomWidthMin = conf.roomWidthMin or 2
  local roomHeightMin = conf.roomHeightMin or 2

  if #availableCells == 0 then error("No availableCells") end
  print("availableCells", #availableCells)
  if #availableCells < roomAmount then error("Less cells available than rooms wished") end

  for _=1,roomAmount do
    local cell = table.pick_random(availableCells)
    print("cell", cell)
    table.remove_value(availableCells, cell)
    local x, y = cell.x, cell.y
    local w = love.math.random(roomWidthMin, cellWidth-1)
    local h = love.math.random(roomHeightMin, cellHeight-1)
    local room = { cellX = x, cellY = y, w = w, h = h, x = (x-1)*cellWidth + outerPadding, y = (y-1)*cellHeight + outerPadding }
    table.insert(rooms, room)
    cells[y][x] = { cellType = "room", metaData = room }
  end


  -- Generate final map object to return
  local tiles = functional.generate(height + outerPadding * 2, function()
    return functional.generate(width + outerPadding * 2, function()
      return tileTypes.wall
    end)
  end)

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
            tiles[yIndex + outerPadding][xIndex + outerPadding] = tileTypes.floor
          end
        end
      end
    end
  end

  local tileToChar = {
    wall = "#",
    floor = "."
  }

  -- Returns x, y, normal {x,y}
  local function getRandomPointInPerimeter(room)
    return room.x+1,room.y+1
    --local left = room.x
    --local right = room.x+room.w
    --local top = room.y
    --local bottom = room.y+room.h

    --if love.math.random() > 0.5 then -- VERTICAL SIDE
    --  local side = love.math.random() > 0.5 and top or bottom
    --  return love.math.random(left, right), side, { 0, side == top and -1 or 1 }
    --else
    --  local side = love.math.random() > 0.5 and left or right
    --  return love.math.random(top, bottom), side, { side == left and -1 or 1, 0 }
    --end
  end

  -- CORRIDOR GENERATION START

  for i, room in ipairs(rooms) do
    for _, nextRoom in ipairs({rooms[i+1], rooms[love.math.random(#rooms)]}) do
      local startX, startY, _ = getRandomPointInPerimeter(room)
      local endX, endY = getRandomPointInPerimeter(nextRoom)
      print("startX,startY,endX,endY",startX,startY,endX,endY)

      local dirX,dirY
      local currentX,currentY = startX,startY
      while currentX ~= endX or currentY ~= endY do
        tiles[currentY][currentX] = tileTypes.floor
        if currentX < endX then dirX = 1 elseif currentX == endX then dirX = 0 else dirX = -1 end
        if currentY < endY then dirY = 1 elseif currentY == endY then dirY = 0 else dirY = -1 end
        if dirX ~= 0 and dirY ~= 0 then dirY = 0 end
        currentX = currentX + dirX
        currentY = currentY + dirY
      end
    end
  end

  -- CORRIDOR GENERATION END

  for _, row in ipairs(tiles) do
    local line = functional.reduce(row, "", function(seed, tileType)
      return seed .. tileToChar[tileType]
    end)
    print(line)
  end

  return {
    tiles = tiles,
    rooms = rooms
  }
end

return dungeonGenerator

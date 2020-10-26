-- NOTE: Dungeon generation script yoinked from:
-- https://gist.githubusercontent.com/Jacajack/36f6401a688dca45ff9734db84803275/raw/0882be6d920b92d6dc73cefcf4ed5a8b604e07af/dungen.lua

local function mkroom(x, y, w, h, id)
  local room = {
    x = x,
    y = y,
    w = w,
    h = h,
    adj = {},
    id = id or 0
  };	

  return room
end

local function roomcoll(a, b, margin)
  margin = margin or 10
  if a == b then return false else
    return math.abs(a.x - b.x) < (a.w + b.w) / 2 + margin and  math.abs(a.y - b.y) < (a.h + b.h) / 2 + margin
  end
end

local function spread(x, y, r, cnt)
  local rooms = {}
  for i = 1, cnt do
    local ang = love.math.random() * 2 * math.pi
    local r = love.math.random() * r
    local x = x + math.floor(math.cos(ang) * r)
    local y = y + math.floor(math.sin(ang) * r)
    local w = math.floor(love.math.random(15, 60))
    local h = math.floor(love.math.random(15, 60))
    rooms[i] = mkroom(x, y, w, h, i)
  end
  return rooms
end

local function cleanup(rooms, cnt)
  for i = #rooms, 1, -1 do
    for j = #rooms, 1, -1 do
      if rooms[i] and rooms[j] and roomcoll(rooms[i], rooms[j]) == true then
        table.remove(rooms, j)
      end
    end
  end

  cnt = #rooms - cnt
  for i = 1, cnt do
    table.remove(rooms, 1)
  end

  return rooms
end

local function mknet(rooms)
  local net = {}
  for i = 1, #rooms do
    for j = 1, #rooms do
      if i ~= j then
        local dist = math.sqrt((rooms[i].x - rooms[j].x) ^ 2 + (rooms[i].y - rooms[j].y) ^ 2) 
        net[#net + 1] = {rooms[i], rooms[j], dist = dist, act = true}
        table.insert(rooms[i].adj, rooms[j])
        table.insert(rooms[j].adj, rooms[i])
      end
    end
  end
  return net
end

local function spantree(rooms, net)
  local function fill(rooms, idtar, idnew)
    for i = 1, #rooms do
      if rooms[i].id == idtar then
        rooms[i].id = idnew
      end
    end
  end

  local function getmin(net)
    local best = 10e9
    local besti = 0
    for i = 1, #net do
      local conn = net[i]
      if conn.dist < best then
        best = conn.dist
        besti = i
      end
    end
    return besti
  end

  local done = {}

  while #net > 0 do
    local besti = getmin(net)
    local best = net[besti]	
    if best[1].id ~= best[2].id then
      fill(rooms, best[1].id, best[2].id)
      done[#done + 1] = best
    end
    table.remove(net, besti)
  end

  return done
end

--Please note, that each corridor can be represented with a room as well!
local function net2halls(net)
  local halls = {}

  for i = 1, #net do
    local conn = net[i]
    local a = conn[1]
    local b = conn[2]

    local mx, my
    if love.math.random() < 0.5 then
      mx = a.x
      my = b.y
    else
      mx = b.x
      my = a.y
    end

    halls[#halls + 1] = {a.x, a.y, mx, my, b.x, b.y}
  end

  return halls
end

local function generate(width, height, r, roomCount, cleanUpCount)
  rooms = spread(width, height, r, roomCount)
  rooms = cleanup(rooms, cleanUpCount)
  net = mknet(rooms)
  net = spantree(rooms, net)
  halls = net2halls(net)

  return {
    rooms = rooms,
    net = net,
    halls = halls
  }
end

return {
  generate = generate
}

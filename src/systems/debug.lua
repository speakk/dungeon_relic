local inGame = require 'states.inGame'

local DebugSystem = Concord.system({players = { "playerControlled" }})

function DebugSystem:enableDebug() -- luacheck: ignore
  inGame.debug = true
end

function DebugSystem:disableDebug() -- luacheck: ignore
  inGame.debug = false
end

function DebugSystem:toggleDebug() -- luacheck: ignore
  print("Toggled")
  inGame.debug = not inGame.debug
end

function DebugSystem:startLuaDebugger() --luacheck: ignore
  debug.debug()
end

function DebugSystem:keyPressed(key)
  if key == 'f2' then
    self:getWorld():emit("startLuaDebugger")
  end
end

local lineHeight = 20

function DebugSystem:drawDebug()
  local lineY = 10

  local function getNewLineY()
    lineY = lineY + lineHeight
    return lineY
  end

  love.graphics.setColor(1,1,1,1)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, getNewLineY())

  -- local map = inGame.mapManager.map

  -- for _, entity in ipairs(self.players) do
  --   local tileX = math.floor(entity.position.vec.x/map.tileSize)
  --   local tileY = math.floor(entity.position.vec.y/map.tileSize)
  --   love.graphics.print("Player location: " .. tostring(tileX) .. "," .. tostring(tileY), 10, getNewLineY())
  -- end
end

function DebugSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "debugNoCamera", DebugSystem.drawDebug, self, false)
end

return DebugSystem

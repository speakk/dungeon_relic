--local Camera = require 'libs.hump.camera'
local Gamera = require 'libs.gamera'
local Gamestate = require 'libs.hump.gamestate'

local CameraSystem = Concord.system({ pool = { 'cameraTarget', 'position', 'velocity', 'speed' }})

local zoomInterpolationSpeed = 1
local zoomFactor = 1 -- This gets dynamically updated based on velocity in update
local minZoomFactor = 1.6
local maxZoomFactor = 2
local cameraMaxX, cameraMaxY = 0, 0

function CameraSystem:init()
  self.camera = Gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  self.map = {}
end

function CameraSystem:attachCamera()
  self.camera:setUpCamera()
end

function CameraSystem:detachCamera()
  self.camera:takeDownCamera()
end

function CameraSystem:mapChange(map)
  self.camera:setWorld(0, 0, map.size.x * map.tileSize, map.size.y * map.tileSize)
  self.map = map
end

function CameraSystem:windowResize(width, height)
  self.camera:setWindow(0, 0, width, height)
end

function CameraSystem:update(dt)
  -- Pick first from target pool until we have implemented camera target switching (if we ever need it)
  local target = self.pool[1]

  if target then
    -- Do linear interpolation between current camera position and the target
    local startX, startY = self.camera:getPosition()
    local targetX, targetY = Vector.split(target.position.vec)
    local lerpSpeed = 0.5
    local finalX = mathx.lerp(startX, targetX, lerpSpeed)
    local finalY = mathx.lerp(startY, targetY, lerpSpeed)
    self.camera:setPosition(finalX, finalY)

    -- Set zoom level based on target velocity (also do linear interpolation
    -- between old value and new)
    -- local previousZoomFactor = zoomFactor
    -- local targetZoomFactor = target.velocity.vec.length * target.speed.value / (target.speed.value) + 1
    -- local interpolatedZoomFactor = mathx.lerp(previousZoomFactor, targetZoomFactor, zoomInterpolationSpeed)
    -- zoomFactor = mathx.clamp(interpolatedZoomFactor, minZoomFactor, maxZoomFactor)
    -- self.camera:setScale(zoomFactor)
    self.camera:setScale(1.3)
  end
end

return CameraSystem

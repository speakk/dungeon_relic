local lume = require 'libs.lume'

local CameraSystem = Concord.system({ pool = { 'cameraTarget', 'position', 'velocity', 'speed' }})

local zoomInterpolationSpeed = 1
local zoomFactor = 1 -- This gets dynamically updated based on velocity in update
local minZoomFactor = 1.6
local maxZoomFactor = 2

function CameraSystem:init()
end

function CameraSystem:setCamera(camera)
  self.camera = camera
  self.camera:setScale(2.5)
  if self.map then
    self.camera:setWorld(0, 0, self.map.size.x * self.map.tileSize, self.map.size.y * map.tileSize)
  end
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
    local lerpSpeed = 0.1
    local finalX = mathx.lerp(startX, targetX, lerpSpeed)
    local finalY = mathx.lerp(startY, targetY, lerpSpeed)
    self.camera:setPosition(finalX, finalY)
    self:getWorld():emit("cameraUpdated", self.camera)

    -- Set zoom level based on target velocity (also do linear interpolation
    -- between old value and new)
    --local previousZoomFactor = zoomFactor
    --local targetZoomFactor = target.velocity.vec.length * 0.2
    --print(targetZoomFactor)
    -- local targetZoomFactor = target.velocity.vec.length * target.speed.value / (target.speed.value) + 1
    --local interpolatedZoomFactor = mathx.lerp(previousZoomFactor, targetZoomFactor, zoomInterpolationSpeed)
    --local interpolatedZoomFactor = lume.lerp(previousZoomFactor, targetZoomFactor, zoomInterpolationSpeed)
    -- zoomFactor = mathx.clamp(interpolatedZoomFactor, minZoomFactor, maxZoomFactor)
    -- self.camera:setScale(zoomFactor)
    --self.camera:setScale(2.5 - interpolatedZoomFactor)
  end
end

return CameraSystem

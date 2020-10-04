local Camera = require 'libs.hump.camera'

local CameraSystem = Concord.system({ pool = { 'cameraTarget', 'position', 'velocity', 'speed' }})

local zoomInterpolationSpeed = 0.05
local zoomFactor = 1 -- This gets dynamically updated based on velocity in update
local minZoomFactor = 1
local maxZoomFactor = 2

function CameraSystem:init()
  self.camera = Camera(0, 0)
  self.camera.smoother = Camera.smooth.damped(20)
end

function CameraSystem:attachCamera()
  self.camera:attach()
end

function CameraSystem:detachCamera()
  self.camera:detach()
end

function CameraSystem:update(dt)
  -- Pick first from target pool until we have implemented camera target switching (if we ever need it)
  local target = self.pool[1]

  if target then
    self.camera:lockPosition(Vector.split(target.position.vec))
    local previousZoomFactor = zoomFactor
    local targetZoomFactor = target.velocity.vec.length * target.speed.value / (target.speed.value) + 1
    local interpolatedZoomFactor = mathx.lerp(previousZoomFactor, targetZoomFactor, zoomInterpolationSpeed)
    zoomFactor = mathx.clamp(interpolatedZoomFactor, minZoomFactor, maxZoomFactor)
    self.camera:zoomTo(zoomFactor)
  end
end

return CameraSystem

local Lighter = require './'

local lighter = Lighter()

local wall = {
    100, 100,
    300, 100,
    300, 300,
    100, 300
}

local lighterWall = lighter:addPolygon(wall)

local lightX, lightY = 500, 500
-- addLight(x,y,radius,r,g,b,a)
local light = lighter:addLight(lightX, lightY, 500, 1, 0.5, 0.5)

function love.update(dt)
    lightX, lightY = love.mouse.getPosition()
    lighter:updateLight(light, lightX, lightY)
end

function love.draw()
    love.graphics.polygon('fill', wall)
    lighter:drawLights()
end

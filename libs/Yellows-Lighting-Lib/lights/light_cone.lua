local light_source = {texture = love.graphics.newImage("libs/Yellows-Lighting-Lib/textures/round.png")}
local rl = require "libs.Yellows-Lighting-Lib"
local shapes = require 'libs.Yellows-Lighting-Lib.HC.shapes'

function light_source:SetX(x)
    local x_diff = x - self.x 
    self.x = x
    self.col:move(x_diff, 0)
    self.shouldupdate[1] = true
end
function light_source:SetY(y)
    local y_diff = y - self.y
    self.y = y
    self.col:move(0, y_diff)
    self.shouldupdate[1] = true
end
function light_source:SetPos(x, y)
    local x_diff = x - self.x 
    local y_diff = y - self.y
    self.x = x
    self.y = y
    self.col:move(x_diff, y_diff)
    self.shouldupdate[1] = true
end

function light_source:GetX()
    return self.x
end
function light_source:GetY()
    return self.y
end
function light_source:GetPos()
    return self.x, self.y
end

function light_source:SetBase(base)
    self.base = base
    self.con = shapes.newPolygonShape(self.x, self.y, self.x - base/2, self.y - self.length, self.x + base/2, self.y - self.length)
    self.shouldupdate[1] = true
end
function light_source:GetBase()
    return self.base
end

function light_source:SetLength(length)
    self.length = length
    self.con = shapes.newPolygonShape(self.x, self.y, self.x - self.base/2, self.y - length, self.x + self.base/2, self.y - length)
    self.shouldupdate[1] = true
end
function light_source:GetLength()
    return self.length
end

function light_source:SetAngle(angle)
    self.angle = angle
    self.shouldupdate[1] = true
    self.col:setRotation(angle * math.pi/180, self.x, self.y)
    
end
function light_source:GetAngle()
    return self.angle
end

function light_source:SetColor(r, g, b, a)
    if type(r) == "table" then
        self.color = r
    else
        self.color = {r, g, b, a}
    end
end
function light_source:GetColor()
    return self.color
end

function light_source:CalcDrawing(polygons)
    self.polygons = polygons

    self.StencilFunc1 = function()
        for _, var in ipairs(self.polygons) do
            love.graphics.polygon("fill", var)
        end
    end
    self.StencilFunc2 = function()
        love.graphics.polygon("fill", self.col._polygon:unpack())
    end
end

function light_source:Draw()
    love.graphics.stencil(self.StencilFunc2, "replace", 1)
    love.graphics.stencil(self.StencilFunc1, "replace", 0, true)
    love.graphics.setStencilTest("equal", 1)

    love.graphics.setColor(self.color or {1, 1, 1})
    love.graphics.draw(self.texture, self.x-self.length, self.y-self.length, 0, self.length*2/self.texture:getWidth())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setStencilTest()
end

function light_source:Remove()
    rl.Remove(self.id)
    self = nil
    self.shouldupdate[1] = true
end

return light_source

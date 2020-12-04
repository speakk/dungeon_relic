--[[
module = {
	{
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1
	},
	{ system=particleSystem2, ... },
	...
}
]]
local LG        = love.graphics
local particles = {}

local image1 = LG.newImage("src/utils/particleSystems/circle.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 2)
ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("ellipse", 8.5445947647095, 9.3390293121338, 0, false)
ps:setEmissionRate(20)
ps:setEmitterLifetime(0.07292278856039)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.01257751788944, 0.13975019752979)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.12956468760967, 0.0099972756579518)
ps:setSizeVariation(0.4112149477005)
ps:setSpeed(90, 100)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename=""})

return particles

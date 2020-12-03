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

local ps = LG.newParticleSystem(image1, 310)
ps:setColors(0.4848484992981, 0, 0, 1, 0.22348484396935, 0, 0, 1)
ps:setDirection(0)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(61.221767425537)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(1, 1)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.13771943747997)
ps:setSizeVariation(0.7757009267807)
ps:setSpeed(0, 58.714492797852)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=7, kickStartDt=0.14285714285714, emitAtStart=245, blendMode="alpha", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename=""})

return particles

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

local image1 = LG.newImage("src/utils/particleSystems/light.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 2)
ps:setColors(0.80681818723679, 0.97804754972458, 1, 0.84848487377167, 0.84848487377167, 0.9655647277832, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(2.8620839118958)
ps:setEmitterLifetime(-1)
ps:setInsertMode("random")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(75, 75)
ps:setParticleLifetime(0.14922215044498, 0.54052269458771)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.16095769405365)
ps:setSizeVariation(0)
ps:setSpeed(90, 100)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.31415927410126)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="light.png", texturePreset="light", shaderPath="", shaderFilename=""})

local ps = LG.newParticleSystem(image1, 9)
ps:setColors(0.48863637447357, 1, 0.94189047813416, 0.21212121844292)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(3.1055598258972)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(76.271186828613, 75)
ps:setParticleLifetime(1, 1)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.50711733102798)
ps:setSizeVariation(0.30529594421387)
ps:setSpeed(0.95107769966125, 3.2802476882935)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(2.2192902565002)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=5, kickStartDt=0.2, emitAtStart=5, blendMode="add", shader=nil, texturePath="light.png", texturePreset="light", shaderPath="", shaderFilename=""})

return particles

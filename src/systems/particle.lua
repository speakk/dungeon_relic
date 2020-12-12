local systemTypes = {
  torch = love.filesystem.load('src/utils/particleSystems/torch_light.lua'),
  magic_torch = love.filesystem.load('src/utils/particleSystems/magic_torch.lua'),
  bloodspurt = love.filesystem.load('src/utils/particleSystems/bloodspurt.lua'),
  small_damage_hit = love.filesystem.load('src/utils/particleSystems/small_damage_hit.lua'),
}

local function createPool(systemType, size)
  return {
    currentIndex = 1,
    systems = functional.generate(size, function(_)
      -- TODO: The [1] grabs the first system from the particle system
      -- array exported from Hot Particles
      -- Which means we only support 1 system per "systemType"
      return systemTypes[systemType]()
    end)
  }
end

local ParticleSystem = Concord.system({ pool = { "particle" }})

-- TODO: Add checking for 'alive' status of system
-- and find next alive. If pool is all used, then increase
-- size of pool
function ParticleSystem:getSystemFromPool(systemType)
  local pool = self.pools[systemType]
  local system = pool.systems[pool.currentIndex]
  pool.currentIndex = pool.currentIndex + 1
  if pool.currentIndex > #(pool.systems) then
    pool.currentIndex = 1
  end

  return system
end

function ParticleSystem:init(_)
  self.pools = {
    torch = createPool("torch", 30),
    magic_torch = createPool("magic_torch", 30),
    small_damage_hit = createPool("small_damage_hit", 30)
  }

  self.pool.onEntityAdded = function(_, entity)
    local particleC = entity.particle
    particleC.systems = {}
    for _, systemType in ipairs(particleC.systemTypes) do
      local system = self:getSystemFromPool(systemType)
      system.alive = true
      for _, actualSystem in ipairs(system) do
        actualSystem.system:start()
      end

      table.insert(particleC.systems, system)
    end
  end

  self.pool.onEntityRemoved = function(_, entity)
    local particleC = entity.particle
    for _, system in ipairs(particleC.systems) do
      for _, actualSystem in ipairs(system) do
        actualSystem.system:stop()
      end
      system.alive = false
    end
  end
end

function ParticleSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    for _, system in ipairs(entity.particle.systems) do
      for _, actualSystem in ipairs(system) do
        actualSystem.system:setPosition(Vector.split(entity.position.vec))
        actualSystem.system:update(dt)
      end
    end
  end
end

function ParticleSystem:drawParticles()
  for _, entity in ipairs(self.pool) do
    for _, system in ipairs(entity.particle.systems) do
      for _, actualSystem in ipairs(system) do
        love.graphics.draw(actualSystem.system, entity.particle.offsetX, entity.particle.offsetY)
      end
    end
  end
end

function ParticleSystem:systemsLoaded()
  self:getWorld():emit("registerLayer", "particles", ParticleSystem.drawParticles, self, true)
end

return ParticleSystem


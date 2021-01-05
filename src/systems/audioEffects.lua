local AudioEffectsSystem = Concord.system({})

-- TODO: Move music playing into inGame itself
function AudioEffectsSystem:init()
  self.music = love.audio.newSource('media/sounds/music/ingame.mp3', 'stream')
  self.music:setVolume(0.1)
  self.music:setLooping(true)
  self.music:play()
end

function AudioEffectsSystem:systemsCleanUp()
  self.music:stop()
end

-- TODO: Pool audio newSource's by type

function AudioEffectsSystem:takeDamage(target, damage) --luacheck: ignore
  -- TODO: Make component to indicate monster (or add special sound component perhaps)
  if target.stateMachine and target.stateMachine.stateType == "basicAi" then
    local sound = love.audio.newSource("media/sounds/fx/monster_hit_1.ogg", "static")
    sound:setVolume(0.3)
    sound:play()
  end
end

function AudioEffectsSystem:healthReachedZero(target) --luacheck: ignore
  if target.stateMachine and target.stateMachine.stateType == "basicAi" then
    local sound = love.audio.newSource("media/sounds/fx/monster_death.ogg", "static")
    sound:setVolume(0.2)
    sound:play()
  end
end

function AudioEffectsSystem:shoot() --luacheck: ignore
  local sound = love.audio.newSource("media/sounds/fx/attack.ogg", "static")
  sound:setVolume(0.1)
  sound:play()
end

function AudioEffectsSystem:bulletCollision() --luacheck: ignore
  local sound = love.audio.newSource("media/sounds/fx/bullet_hit_2.ogg", "static")
  sound:setVolume(0.05)
  sound:play()
end

function AudioEffectsSystem:monsterPrepareAttack() --luacheck: ignore
  local sound = love.audio.newSource("media/sounds/fx/monster_prepare.ogg", "static")
  sound:setVolume(0.009)
  sound:play()
end

return AudioEffectsSystem

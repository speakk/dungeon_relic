local Gamestate = require 'libs.hump.gamestate'
require 'libs.batteries':export()

-- Enable require without specifying 'src' in the beginning
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";src/?.lua")

-- -- Global declarations START -- --
Class = require 'libs.hump.class'
inspect = require 'libs.inspect'
mediaManager = require 'mediaManager'()
Concord = require 'libs.concord'

-- CONCORD CONFIG START --
-- Create global Concord aliases for ease of access

ECS = {
  c = Concord.components,
  s = {}
}

Concord.utils.loadNamespace("src/components")
Concord.utils.loadNamespace("src/systems", ECS.s)
-- CONCORD CONFIG END --

-- -- Global declarations END -- --

local inGame = require 'states.inGame'

Gamestate.registerEvents()
Gamestate.switch(inGame)

local Gamestate = require 'libs.hump.gamestate'

require 'libs.batteries':export()

love.window.setMode(800, 600, {resizable=true})
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Enable require without specifying 'src' in the beginning
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";src/?.lua")

-- -- Global declarations START -- --
Class = require 'libs.hump.class'
inspect = require 'libs.inspect'
mediaManager = require 'mediaManager'()
Concord = require 'libs.concord'
Vector = require 'libs.brinevector'

-- CONCORD CONFIG START --
-- Create global Concord aliases for ease of access

local assemblageUtil = require 'utils.assemblage'

ECS = {
  c = Concord.components,
  a = assemblageUtil.createAssemblageHierarchy("src/assemblages"),
  s = {}
}

Concord.utils.loadNamespace("src/components")
Concord.utils.loadNamespace("src/systems", ECS.s)
-- CONCORD CONFIG END --

-- -- Global declarations END -- --

local inGame = require 'states.inGame'
local mainMenu = require 'states.mainMenu'

Gamestate.registerEvents()
Gamestate.switch(mainMenu)

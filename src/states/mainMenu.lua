local Gamestate = require 'libs.hump.gamestate'

local inGame = require 'states.inGame'

local images = {
  background = love.graphics.newImage('media/ui/mainmenu/menuscreen.png'),
  playButton = love.graphics.newImage('media/ui/mainmenu/button_play.png'),
  playButtonHover = love.graphics.newImage('media/ui/mainmenu/button_play_hover.png'),
  quitButton = love.graphics.newImage('media/ui/mainmenu/button_quit.png'),
  quitButtonHover = love.graphics.newImage('media/ui/mainmenu/button_quit_hover.png')
}

local mainMenu = {}

local scale = 4

local function startGame()
  Gamestate.switch(inGame)
end

local function quit()
  love.event.quit()
end


local function createButton(y, image, hoverImage, clickFunction, hoverFunction)
  local w, h = image:getDimensions()
  return {
    y = y,
    w = w,
    h = h,
    activeImage = image,
    normalImage = image,
    hoverImage = hoverImage,
    clickFunction = clickFunction,
    hoverFunction = hoverFunction
  }
end


function mainMenu:enter() --luacheck: ignore
  self.elements = {
    createButton(160, images.playButton, images.playButtonHover, startGame),
    createButton(190, images.quitButton, images.quitButtonHover, quit)
  }

  self.selectedIndex = nil

  self.music = love.audio.newSource('media/sounds/music/menu.mp3', 'stream')
  self.music:setVolume(0.1)
  self.music:setLooping(true)
  self.music:play()
end

function mainMenu:leave()
  self.music:stop()
end

local function getCentered(image)
  local screenW, screenH = love.graphics.getDimensions()
  local imageW, imageH = image:getDimensions()
  return ((screenW / scale - imageW) / 2), ((screenH / scale - imageH) / 2)
end

function mainMenu:update(dt) -- luacheck: ignore
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX = mouseX / scale
  mouseY = mouseY / scale

  for i, element in ipairs(self.elements) do
    local x = getCentered(element.activeImage, scale)
    local y = element.y
    local w = element.w
    local h = element.h
    if mouseX > x and
      mouseX < x + w and
      mouseY > y and
      mouseY < y + h then

      self.selectedIndex = i

      if love.mouse.isDown(1) then
        element:clickFunction()
      end
    end
  end
end

function mainMenu:keypressed(key)
  if key == 'down' then
    if not self.selectedIndex then self.selectedIndex = 0 end
    self.selectedIndex = self.selectedIndex + 1
  end
  if key == 'up' then
    if not self.selectedIndex then self.selectedIndex = 0 end
    self.selectedIndex = self.selectedIndex - 1
  end

  if self.selectedIndex then
    if self.selectedIndex > #(self.elements) then
      self.selectedIndex = 1
    elseif self.selectedIndex < 1 then
      self.selectedIndex = #(self.elements)
    end
  end

  if (key == 'space' or key == 'return') then
    if self.selectedIndex then
      self.elements[self.selectedIndex].clickFunction()
    end
  end
end

local function drawElement(element, active)
  element.activeImage = active and element.hoverImage or element.normalImage
  local x = getCentered(element.activeImage, scale)
  love.graphics.draw(element.activeImage, x, element.y)
end

function mainMenu:draw() -- luacheck: ignore
  love.graphics.push()
  love.graphics.scale(scale)

  local x = getCentered(images.background)
  love.graphics.draw(images.background, x, 0)

  for i, element in ipairs(self.elements) do
    drawElement(element, self.selectedIndex == i)
  end

  -- x = getCentered(images.playButton, scale)
  -- love.graphics.draw(images.playButton, x, 160)
  -- x = getCentered(images.quitButton, scale)
  -- love.graphics.draw(images.quitButton, x, 200)

  love.graphics.pop()
end

return mainMenu

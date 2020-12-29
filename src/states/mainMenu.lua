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

function mainMenu:enter() --luacheck: ignore
end

local function getCentered(image, scale)
  local screenW, screenH = love.graphics.getDimensions()
  local imageW, imageH = image:getDimensions()
  return ((screenW / scale - imageW) / 2), ((screenH / scale - imageH) / 2)
end

local scale = 4

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

function mainMenu:enter() -- luacheck: ignore
  self.elements = {
    createButton(160, images.playButton, images.playButtonHover, function(_)
      Gamestate.switch(inGame)
    end),
    createButton(190, images.quitButton, images.quitButtonHover, function(_)
      love.event.quit()
    end)
  }
end

function mainMenu:update(dt) -- luacheck: ignore
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX = mouseX / scale
  mouseY = mouseY / scale

  for _, element in ipairs(self.elements) do
    element.hovered = false
    local x = getCentered(element.activeImage, scale)
    local y = element.y
    local w = element.w
    local h = element.h
    if mouseX > x and
      mouseX < x + w and
      mouseY > y and
      mouseY < y + h then

      element.hovered = true

      if love.mouse.isDown(1) then
        element:clickFunction()
      end
    end
  end
end

local function drawElement(element, scale)
  element.activeImage = element.hovered and element.hoverImage or element.normalImage
  local x = getCentered(element.activeImage, scale)
  love.graphics.draw(element.activeImage, x, element.y)
end

function mainMenu:draw() -- luacheck: ignore
  love.graphics.push()
  love.graphics.scale(scale)

  local x = getCentered(images.background, scale)
  love.graphics.draw(images.background, x, 0)

  for _, element in ipairs(self.elements) do
    drawElement(element, scale)
  end

  -- x = getCentered(images.playButton, scale)
  -- love.graphics.draw(images.playButton, x, 160)
  -- x = getCentered(images.quitButton, scale)
  -- love.graphics.draw(images.quitButton, x, 200)

  love.graphics.pop()
end

return mainMenu

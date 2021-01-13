local settings = require 'settings'

return Class {
  init = function(self, width, height)
    self.imageData = love.image.newImageData(width, height)
    self.image = love.graphics.newImage(self.imageData)
    self.currentX = 0
    self.currentY = 0
    self.lastRowHeight = 0
    self.width = width
    self.height = height
  end,
  -- Returns mediaEntity
  addImage = function(self, imageData, framesX, framesY)
    local padding = settings.spritePadding -- Padding for each sprite by px

    framesX = framesX or 1
    framesY = framesY or 1

    local mediaEntity = {
      origin = { x = 0, y = 0 },
      quads = {}
    }

    local spriteWidth, spriteHeight = imageData:getDimensions()

    if self.currentX + spriteWidth + (framesX * padding * 2) > self.image:getWidth() then
      self.currentX = 0
      self.currentY = self.currentY + self.lastRowHeight
      self.lastRowHeight = 0
    end

    if self.currentX + spriteWidth > self.image:getWidth() then
      error("Trying to add image outside of texture width bound")
    end

    if self.currentY + spriteHeight > self.image:getHeight() then
      error("Ran out of texture space! Tell the dev, wtf!")
    else

      local quadW = spriteWidth / framesX + padding*2
      local quadH = spriteHeight / framesY + padding*2
      local sourceW, sourceH = spriteWidth / framesX, spriteHeight / framesY

      for x=1, framesX do
        for y=1, framesY do
          local sourceX,sourceY = (x - 1) * sourceW, (y - 1) * sourceH

          local quadX = self.currentX + (x - 1) * quadW
          local quadY = self.currentY + (y - 1) * quadH
          self.imageData:paste(imageData, quadX + padding, quadY + padding, sourceX, sourceY, sourceW, sourceH)
          local quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, self.image:getDimensions())
          table.insert(mediaEntity.quads, quad)
        end
      end

      self.currentX = self.currentX + spriteWidth + (framesX * padding * 2)

      if spriteHeight > self.lastRowHeight then
        self.lastRowHeight = spriteHeight + padding * 2
      end

      print("spriteWidth, currentX, padding, framesX, image:getWidth", spriteWidth, self.currentX, padding, framesX, self.image:getWidth())
    end

    self:refreshImage()

    return mediaEntity
  end,
  refreshImage = function(self)
    self.image:replacePixels(self.imageData)
  end,
  getImage = function(self)
    return self.image
  end
}

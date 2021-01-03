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
    framesX = framesX or 1
    framesY = framesY or 1

    local mediaEntity = {
      origin = { x = 0, y = 0 },
      quads = {}
    }

    local padding = 1

    local spriteWidth, spriteHeight = imageData:getDimensions()
    spriteWidth = spriteWidth + padding
    spriteHeight = spriteHeight + padding

    if self.currentY + spriteHeight > self.image:getHeight() then
      error("Ran out of texture space! Tell the dev, wtf!")
    else
      self.imageData:paste(imageData, self.currentX + padding * 2, self.currentY + padding * 2)


      for x=1, framesX do
        for y=1, framesY do
          local quadW = (spriteWidth + padding) / framesX
          local quadH = (spriteHeight + padding) / framesY
          local quadX = self.currentX + (x - 1) * (quadW + padding * 0)
          local quadY = self.currentY + (y - 1) * (quadH + padding * 0)
          local quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, self.image:getDimensions())
          table.insert(mediaEntity.quads, quad)
        end
      end

      self.currentX = self.currentX + spriteWidth + padding*2

      if spriteHeight > self.lastRowHeight then
        self.lastRowHeight = spriteHeight
      end

      if self.currentX + spriteWidth > self.image:getWidth() then
        self.currentX = 0
        self.currentY = self.currentY + self.lastRowHeight + padding * 2
        self.lastRowHeight = 0
      end
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

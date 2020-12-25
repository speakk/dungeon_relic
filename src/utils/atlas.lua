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

    local spriteWidth, spriteHeight = imageData:getDimensions()

    if self.currentY + spriteHeight > self.image:getHeight() then
      error("Ran out of texture space! Tell the dev, wtf!")
    else
      self.imageData:paste(imageData, self.currentX, self.currentY)


      for x=1, framesX do
        for y=1, framesY do
          local quadW = spriteWidth / framesX
          local quadH = spriteHeight / framesY
          local quadX = self.currentX + (x - 1) * quadW
          local quadY = self.currentY + (y - 1) * quadH
          local quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, self.image:getDimensions())
          table.insert(mediaEntity.quads, quad)
        end
      end

      self.currentX = self.currentX + spriteWidth

      if spriteHeight > self.lastRowHeight then
        self.lastRowHeight = spriteHeight
      end

      if self.currentX + spriteWidth > self.image:getWidth() then
        self.currentX = 0
        self.currentY = self.currentY + self.lastRowHeight
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

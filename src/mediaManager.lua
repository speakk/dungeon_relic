local lfs = love.filesystem

local MediaManager = Class {
  init = function(self)
    self.tree = {} -- Stores mediaEntity objects indexed by file path hierarchy
    self.mediaEntities = {} -- A flat list of the above for ease of iteration
    fillTree("media/images", "", self.tree, self.mediaEntities) -- Fill above 2 tables
    self.atlasCanvas = createAtlas(self.mediaEntities)
  end,
  getTexture = function(self, path)
    return self:getMediaEntity(path).texture
  end,
  getMediaEntity = function(self, path)
    return getDepth(self.tree, 'media.images.' .. path)
  end,
  getAtlas = function(self)
    return self.atlasCanvas
  end
}

function fillTree(folder, fileTree, tree, mediaEntities)
  local filesTable = lfs.getDirectoryItems(folder)
  for i,v in ipairs(filesTable) do
    local file = folder.."/"..v
    local info = lfs.getInfo(file)
    if info.type == "file" then
      fileTree = fileTree.."\n"..file
      print("file", file)

      local mediaEntity = {
        fileName = file
      }

      if lfs.getInfo(file .. '.lua') then
        mediaEntity.metaData = require(file .. '.lua')
      else
        mediaEntity.metaData = {}
      end

      setDepth(tree, file, mediaEntity, '/')
      table.push(mediaEntities,mediaEntity)
    elseif info.type == "directory" then
      fileTree = fileTree.."\n"..file.." (DIR)"
      fileTree = fillTree(file, fileTree, tree, mediaEntities)
    end
  end
  return fileTree
end

function getDepth(obj, path, splitter)
  splitter = splitter or '.'
  local tags = stringx.split(path, splitter)
  local len = #tags - 1;
  for i=1,len+1 do
    local name = tags[i]
    if not obj[name] then
      obj[name] = {}
    end
    obj = obj[name];
  end

  return obj
end

function setDepth(obj, path, value, splitter)
  splitter = splitter or '.'
  local tags = stringx.split(path, splitter)
  local len = #tags - 1;
  for i=1,len do
    local name = tags[i]
    if not obj[name] then
      obj[name] = {}
    end
    obj = obj[name];
  end

  -- Remove dir path
  local fileName = path:match("^.+/(.+)$")
  -- Remove extension
  local fileShort = fileName:match("(.+)%..+")
  obj[fileShort] = value
end

function createAtlas(mediaEntities)
  local atlasWidth = 1280
  local atlasHeight = 1280
  local atlasCanvas = love.graphics.newCanvas(atlasWidth, atlasHeight)
  do
    love.graphics.setCanvas(atlasCanvas)
    love.graphics.clear()

    local currentX = 0
    local currentY = 0
    local lastRowHeight = 0

    for _, mediaEntity in ipairs(mediaEntities) do
      local sprite = love.graphics.newImage(mediaEntity.fileName)
      local spriteWidth, spriteHeight = sprite:getDimensions()

      love.graphics.draw(sprite, currentX, currentY)

      local quad = love.graphics.newQuad(currentX, currentY, spriteWidth, spriteHeight, atlasCanvas:getDimensions())
      mediaEntity.texture = quad

      -- If no origin, default to bottom center
      mediaEntity.origin = mediaEntity.metaData.origin or {
        x = spriteWidth/2,
        y = spriteHeight
      }

      currentX = currentX + spriteWidth
      if spriteHeight > lastRowHeight then
        lastRowHeight = spriteHeight
      end

      if currentX + spriteWidth > atlasWidth then
        currentX = 0
        currentY = currentY + lastRowHeight
        lastRowHeight = 0
      end
    end
  end

  love.graphics.setCanvas()

  return atlasCanvas
end

return MediaManager

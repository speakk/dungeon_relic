local lfs = love.filesystem

local function simplifyFileName(path)
  -- Remove extension
  return path:match("(.+)%..+"):gsub("/", ".")
end

local function fillTree(folder, fileTree, tree, mediaEntities, root)
  if not root then root = folder end

  local filesTable = lfs.getDirectoryItems(folder)
  for _, fileName in ipairs(filesTable) do
    local file = folder .. "/" .. fileName
    local info = lfs.getInfo(file)
    if info.type == "file" then
      fileTree = fileTree .. "\n" ..file

      local mediaEntity = {
        fileName = file
      }

      if lfs.getInfo(file .. '.lua') then
        mediaEntity.metaData = require(file .. '.lua')
      else
        mediaEntity.metaData = {}
      end

      local name = simplifyFileName(file:gsub(root, ""):sub(2, #file))
      tree[name] = mediaEntity
      table.push(mediaEntities,mediaEntity)
    elseif info.type == "directory" then
      fileTree = fileTree.."\n"..file.." (DIR)"
      fileTree = fillTree(file, fileTree, tree, mediaEntities, root)
    end
  end
  return fileTree
end


local function createAtlas(mediaEntities)
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

      mediaEntity.atlas = atlasCanvas

      love.graphics.draw(sprite, currentX, currentY)

      local quad = love.graphics.newQuad(currentX, currentY, spriteWidth, spriteHeight, atlasCanvas:getDimensions())
      mediaEntity.quad = quad

      -- If no origin, default to bottom center
      mediaEntity.origin = mediaEntity.metaData.origin or {
        x = spriteWidth/2,
        y = spriteHeight
      }

      print("Setting origin at", mediaEntity.origin.x, mediaEntity.origin.y, "for", mediaEntity.fileName)

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

local MediaManager = Class {
  init = function(self)
    self.tree = {} -- Stores mediaEntity objects indexed by file path hierarchy
    local mediaEntities = {} -- A flat list of the above for ease of iteration
    fillTree("media/images", "", self.tree, mediaEntities) -- Fill above 2 tables
    self.atlasCanvas = createAtlas(mediaEntities)
  end,
  getTexture = function(self, path)
    return self:getMediaEntity(path).quad
  end,
  getMediaEntity = function(self, path)
    return self.tree[path]
  end,
  setMediaEntity = function(self, path, mediaEntity)
    print("setMediaEntity", path, mediaEntity)
    self.tree[path] = mediaEntity
  end,
  getAtlas = function(self)
    return self.atlasCanvas
  end
}


return MediaManager

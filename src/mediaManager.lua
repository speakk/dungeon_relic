local lfs = love.filesystem

local function simplifyFileName(path)
  -- Remove extension
  return path:match("(.+)%..+"):gsub("/", ".")
end

local function fillTree(folder, fileTree, root, result)
  if not root then root = folder end
  result = result or {}

  local filesTable = lfs.getDirectoryItems(folder)
  for _, fileName in ipairs(filesTable) do
    local file = folder .. "/" .. fileName
    local info = lfs.getInfo(file)
    if info.type == "file" then
      local extension = file:match("[^.]+$")
      if extension == "png" or extension == "jpg" then
        fileTree = fileTree .. "\n" ..file

        -- local mediaEntity = {
        --   fileName = file
        -- }

        local name = simplifyFileName(file:gsub(root, ""):sub(2, #file))

        -- if lfs.getInfo(file .. '_metadata.lua') then
        --   mediaEntity.metaData = require((file .. '_metadata'):gsub('/', '.'))
        -- else
        --   mediaEntity.metaData = {}
        -- end

        local resultEntity = {
          fileName = file,
          selector = name
        }

        local metaDataName = (file:gsub(extension, "") .. 'lua'):gsub("#.", "/")
        if lfs.getInfo(metaDataName) then
          resultEntity.metaData = require(metaDataName:gsub(".lua", ""))
        end

        table.insert(result, resultEntity)
      end
      --mediaEntity.name = name
      --tree[name] = mediaEntity
      --table.push(mediaEntities,mediaEntity)
    elseif info.type == "directory" then
      fileTree = fileTree.."\n"..file.." (DIR)"
      fileTree, result = fillTree(file, fileTree, root, result)
    end
    --end
  end

  return fileTree, result
end


local function createMediaEntities(self, fileEntries)
  local atlasWidth = 1280
  local atlasHeight = 1280
  local currentCanvas

  local currentX = 0
  local currentY = 0
  local lastRowHeight = 0

  self.mediaEntities = {}

  local currentFileEntryIndex = 1
  while currentFileEntryIndex <= #fileEntries do

    local fileEntry = fileEntries[currentFileEntryIndex]
    local metaData = fileEntry.metaData

    if not currentCanvas then
      currentCanvas = love.graphics.newCanvas(atlasWidth, atlasHeight)
      love.graphics.setCanvas(currentCanvas)
      love.graphics.clear()

      currentX = 0
      currentY = 0
      lastRowHeight = 0
    end

    local framesX = metaData and metaData.framesX or 1
    local framesY = metaData and metaData.framesY or 1

    local sprite = love.graphics.newImage(fileEntry.fileName)
    local spriteWidth, spriteHeight = sprite:getDimensions()

    if currentY + spriteHeight > atlasHeight then
      currentCanvas = nil
    else
      love.graphics.draw(sprite, currentX, currentY)

      local mediaEntity = {
        atlas = currentCanvas,
        origin = { x = 0.5, y = 0.5 },
        quads = {}
      }

      if metaData and metaData.origin then
        mediaEntity.origin = metaData.origin
      end

      self:setMediaEntity(fileEntry.selector, mediaEntity)

      for x=1, framesX do
        for y=1, framesY do
          local quadW = spriteWidth / framesX
          local quadH = spriteHeight / framesY
          local quadX = currentX + (x - 1) * quadW
          local quadY = currentY + (y - 1) * quadH
          local quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, currentCanvas:getDimensions())
          table.insert(mediaEntity.quads, quad)
        end
      end

      currentX = currentX + spriteWidth

      if spriteHeight > lastRowHeight then
        lastRowHeight = spriteHeight
      end

      if currentX + spriteWidth > atlasWidth then
        currentX = 0
        currentY = currentY + lastRowHeight
        lastRowHeight = 0
      end

      currentFileEntryIndex = currentFileEntryIndex + 1
    end
  end

  love.graphics.setCanvas()
end

local MediaManager = Class {
  init = function(self)
    self.tree = {}
    local _, fileEntities = fillTree("media/images", "") -- Fill above 2 tables
    --self.mediaEntities = createMediaEntities(self, fileEntities)
    createMediaEntities(self, fileEntities)
  end,
  getMediaEntity = function(self, path)
    return self.tree[path]
  end,
  setMediaEntity = function(self, path, mediaEntity)
    --print("Setting mediaEntity", path)
    self.tree[path] = mediaEntity
  end,
  getAtlas = function(self)
    return self.atlasCanvas
  end
}


return MediaManager

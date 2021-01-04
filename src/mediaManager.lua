local lfs = love.filesystem
local json = require 'libs.json'
local Atlas = require 'utils/atlas'

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
        local name = simplifyFileName(file:gsub(root, ""):sub(2, #file))

        local resultEntity = {
          fileName = file,
          selector = name
        }

        local metaDataName = (file:gsub(extension, "") .. 'lua'):gsub("#.", "/")
        if lfs.getInfo(metaDataName) then
          resultEntity.metaData = require(metaDataName:gsub(".lua", ""))
        end

        local asepriteMetaDataName = (file:gsub(extension, "") .. 'json'):gsub("#.", "/")
        if lfs.getInfo(asepriteMetaDataName) then
          local fileData = love.filesystem.read("string", asepriteMetaDataName)
          resultEntity.asepriteMetaData = json.decode(fileData)
          --print("Got asepriteMetaData", inspect(resultEntity.asepriteMetaData))
        end

        table.insert(result, resultEntity)
      end
    elseif info.type == "directory" then
      fileTree = fileTree.."\n"..file.." (DIR)"
      fileTree, result = fillTree(file, fileTree, root, result)
    end
  end

  return fileTree, result
end

local function createMediaEntities(self, fileEntries)
  local preloadAtlas = Atlas(1280, 1280)
  self.mediaEntities = {}

  for _, fileEntry in ipairs(fileEntries) do
    local metaData = fileEntry.metaData

    local framesX = metaData and metaData.framesX or 1
    local framesY = metaData and metaData.framesY or 1

    local imageData = love.image.newImageData(fileEntry.fileName)
    local mediaEntity = preloadAtlas:addImage(imageData, framesX, framesY)
    self:setMediaEntity(fileEntry.selector, mediaEntity)
  end

  return preloadAtlas
end

local MediaManager = Class {
  init = function(self)
    self.atlases = {}
    self.tree = {}
    local _, fileEntities = fillTree("media/images", "") -- Fill above 2 tables
    self.atlases["autoLoaded"] = createMediaEntities(self, fileEntities)
    self.atlases["dynamic"] = Atlas(3000, 3000)
  end,
  resetDynamicAtlas = function(self)
    self.atlases["dynamic"] = Atlas(3000, 3000)
  end,
  getMediaEntity = function(self, path)
    if not self.tree[path] then error("No mediaEntity found for " .. path) end
    return self.tree[path]
  end,
  setMediaEntity = function(self, path, mediaEntity)
    self.tree[path] = mediaEntity
  end,
  getAtlas = function(self, id)
    return self.atlases[id]
  end,
  addAtlas = function(self, id, atlas)
    self.atlases[id] = atlas
  end
}


return MediaManager

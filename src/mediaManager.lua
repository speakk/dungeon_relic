local lfs = love.filesystem

local MediaManager = Class {
  init = function(self)
    self.tree = {}
    fillTree("media/images", "", self.tree)
    print("TREE IN END", inspect(self.tree))
  end,
  getImg = function(self, path)
    return getDepth(self.tree, 'media.images.' .. path)
  end
}

-- This function will return a string filetree of all files
-- in the folder and files in all subfolders
function fillTree(folder, fileTree, tree)
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
      end

      --setBySelector(tree, file, '/', mediaEntity)
      setDepth(tree, file, mediaEntity, '/')
    elseif info.type == "directory" then
      fileTree = fileTree.."\n"..file.." (DIR)"
      fileTree = fillTree(file, fileTree, tree)
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

-- NOTE: Hardcoded '/'
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

return MediaManager

local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local ContentProvider = System.getContentProvider();
local Directory = ContentProvider.get("UwU.FileSystem.Directory");

---@class RootDirectory
---@field className string
---@field class table
local RootDirectory = {};
RootDirectory.__index = Directory;

-- Constructors
function RootDirectory.new(name)
    local directory = setmetatable(Directory.construct(name, nil), RootDirectory);
    directory.__children = {};
    directory.className = "RootDirectory";
    directory.class = RootDirectory;
    
    if not fs.exists(directory.path) then
        directory:__addToDrive();
    end

    return directory:__generateProxy();
end

-- Public methods

function RootDirectory:move()
    error("Cannot move root directory!");
end

function RootDirectory:copy()
    error("Cannot copy root directory!");
end

function RootDirectory:rename()
    error("Cannot rename root directory!");
end

function RootDirectory:delete()
    error("Cannot delete root directory!");
end

-- Private methods

function RootDirectory:__generatePath()
    return ""
end

setmetatable(RootDirectory, {
    __index = Directory;
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return RootDirectory;
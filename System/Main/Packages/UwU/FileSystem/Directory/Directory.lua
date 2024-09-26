local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local ContentProvider = System.getContentProvider();
local FsNode = ContentProvider.get("UwU.FileSystem.FsNode");

---@class Directory
---@field __children table
---@field className string
---@field class table
local Directory = {};
Directory.__index = Directory;

-- Constructors
function Directory.construct(name, parent)
    local directory = setmetatable(FsNode.construct(name, parent), Directory);
    directory.__children = {};
    directory.className = "Directory";
    directory.class = Directory;
    
    if not fs.exists(directory.path) then
        directory:__addToDrive();
    end

    return directory;
end

function Directory.new(name, parent)
    local directory = Directory.construct(name, parent);
    local proxy = directory:__generateProxy();

    if parent then
        parent.__children[name] = proxy;
    end

    return proxy;
end

-- Public methods

function Directory:getChildren()
    return self.__children;
end

function Directory:get(name)
    return self.__children[name];
end

function Directory:findChildByName(name)
    if self.__children[name] then
        return self.__children[name];
    end
end

function Directory:getChildCount()
    local counter = 0;
    for _, _ in pairs(self.__children) do
        counter = counter + 1;
    end

    return counter;
end

function Directory:clear()
    -- FIXME: Replace with 
    for _, child in pairs(self.__children) do
        child:delete();
    end
end

function Directory:isDirectory()
    return true;
end

function Directory:getTotalSize()
    -- FIXME: Method is empty currently!
    return 0;
end

-- Private methods
function Directory:addChild(object)
    if self.__children[object.displayName] ~= nil then
        error("Such child already exists!");
    end

    self.__children[object.displayName] = object;
end

function Directory:removeChild(object)
    if self.__children[object.displayName] == nil then
        error("This child is not present here!");
    end

    self.__children[object.displayName] = nil;
end

function Directory:__addToDrive()
    fs.makeDir(self.path);
end

function Directory:__updateChildren()
    for _, child in pairs(self.__children) do 
        child:__updatePath();

        if child:isDirectory() then 
            child:__updateChildren();
        end
    end
end

setmetatable(Directory, {
    __index = FsNode;
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return Directory;
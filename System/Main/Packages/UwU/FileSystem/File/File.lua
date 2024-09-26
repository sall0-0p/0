local ContentProvider = System.getContentProvider();
local FsNode = ContentProvider.get("UwU.FileSystem.FsNode");

---@class File
---@field className string
---@field class table
---@field metadata table
local File = {};
File.__index = File;

--FIXME: Change to ContentProvider!!!
local MetadataManager = require(".System.Main.Services.UwU.FileSystem.MetadataManager.MetadataManager");

-- Constructors

function File.construct(name, parent)
    local file = setmetatable(FsNode.construct(name, parent), File);
    file.className = "File";
    file.class = File;

    if not fs.exists(file.path) then
        file:__addToDrive();
    end

    return file;
end

function File.new(name, parent)
    local file = File.construct(name, parent);
    local proxy = file:__generateProxy();

    if parent then
        parent.__children[name] = proxy;
    end

    file.metadata = MetadataManager.buildMeta(file);

    return proxy;
end

-- Public methods

function File:open(mode)
    -- TODO: Remake for custom class!
    return fs.open(self.path, mode);
end

function File:getSize()
    return fs.getSize(self.path);
end

function File:IsDirectory()
    return false;
end

-- Private methods

function File:__addToDrive()
    local file = fs.open(self.path, "w");
    file.close();
end

setmetatable(File, {
    __index = FsNode;
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return File;
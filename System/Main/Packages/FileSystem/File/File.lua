local ContentProvider = System.getContentProvider();
local FsNode = ContentProvider.get("FileSystem.FsNode");

---@class File
local File = {};
File.__index = File;

-- Constructors

function File.new(name, parent)
    local file = setmetatable(FsNode(name, parent), File);
    file.className = "File";
    file.class = File;

    if not fs.exists(file.path) then
        file:__addToDrive();
    end

    return file;
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
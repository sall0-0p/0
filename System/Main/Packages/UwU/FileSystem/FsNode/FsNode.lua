local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

--FIXME: Change to ContentProvider!!!
local MetadataManager = require(".System.Main.Services.UwU.FileSystem.MetadataManager.MetadataManager");

---@class FsNode
---@field displayName string
---@field simplifiedName string
---@field parent FsNode
---@field path string
---@field isReadOnly boolean

local FsNode = {};
FsNode.__index = FsNode;
FsNode.className = "FsNode";
FsNode.class = FsNode;

-- Constructors

function FsNode.construct(displayName, parent)
    -- enforce existance of file
    -- TODO: Add analogue of instanceof
    if parent and type(parent) == "table" and not (parent.className == "Directory" or parent.className == "RootDirectory") then
        error("Parent must be a directory!");
    end

    -- check if such file already exists
    if parent and parent.__children[displayName] then
        error(string.format("File %s already exists in directory %s", displayName, parent.displayName));
    end

    local node = setmetatable({}, FsNode);
    node.displayName = displayName;
    node.simplifiedName = node:__simplifyName();
    node.parent = parent;
    node.path = node:__generatePath();
    node.isReadOnly = fs.isReadOnly(node.path);

    return node;
end

function FsNode.new(displayName, parent)
    local node = FsNode.construct(displayName, parent);
    local proxy = node:__generateProxy()

    if parent then
        parent.__children[displayName] = proxy;
    end

    return proxy;
end

-- Public methods
function FsNode:isDirectory()
    return false
end

function FsNode:move(newParent)
    if newParent == nil then
        self:delete();
        return
    end

    -- FIXME: Add checks
    if newParent and not newParent.className == "Directory" then
        error("newParent has to be a directory!");
    end

    local oldPath = self.path;
    if self.parent then
        self.parent:removeChild(self.proxy);
    end

    newParent:addChild(self.proxy);
    rawset(self, "parent", newParent);
    self.path = self:__generatePath();
    self.readOnly = fs.isReadOnly(self.path);

    if oldPath then
        fs.move(oldPath, self.path);
        MetadataManager.changeMeta(oldPath, self.path);
    end

    if self.__children then
        self:__updateChildren()
    end

    -- FIXME: Update metadata
    return self;
end

function FsNode:copy(newParent)
    if not self.parent then
        error("Such operations are not allowed on parentless entities");
    end

    if not (newParent and newParent.className == "Directory") then
        error("newParent has to be a directory!");
    end

    local newNode = self:__clone();
    local newNodeProxy = newNode:__generateProxy();
    newNodeProxy:move(newParent);

    if newNode.path then
        fs.copy(self.path, newNode.path);
    end

    return newNode;
end

function FsNode:delete()
    if self.parent then
        self.parent:removeChild(self.proxy);
    end

    if self.path then
        fs.delete(self.path);
        MetadataManager.clean(self.path);
    end
end

function FsNode:rename(newName)
    if not self.parent then
        error("Such operations are not allowed on parentless nodes");
    end

    if self.parent and self.parent.__children[newName] then
        error("File with this name already exists!");
    end

    local oldPath = self.path;
    
    self.parent:removeChild(self.proxy);
    self.displayName = newName;
    self.simplifiedName = self:__simplifyName();
    self.path = self:__generatePath();
    self.parent:addChild(self.proxy);

    fs.move(oldPath, self.path);
    MetadataManager.changeMeta(oldPath, self.path);

    if self.__children then
        self:__updateChildren()
    end
end

-- getters, required as I am planning to use proxy tables.
function FsNode:getPath()
    return self.path;
end

function FsNode:getSimplifiedName()
    return self.simplifiedName;
end

function FsNode:getDisplayName()
    return self.displayName;
end

function FsNode:isReadOnly()
    return self.readOnly;
end

-- Private methods
function FsNode:__generatePath()
    local ancestor = self;
    local ancestors = {};

    while ancestor and ancestor.className ~= "RootDirectory" do
        table.insert(ancestors, ancestor);
        ancestor = ancestor.parent;
    end

    local result = "";
    for i = #ancestors, 1, -1 do
        local node = ancestors[i];
        result = result .. "/" .. node.simplifiedName;
    end

    return result;
end

function FsNode:__updatePath()
    self.path = self:__generatePath();
end

function FsNode:__simplifyName()
    local simplifiedName = self.displayName:gsub("%s", "_");
    simplifiedName = simplifiedName:gsub("[^%w_.-]", "");
    return simplifiedName;
end

function FsNode:__generateProxy()
    local proxy = setmetatable({}, {
        __index = function (proxy, key)
            if self:isDirectory() then
                if self.__children[key] then
                    return self.__children[key];
                end
            end

            return self[key];
        end,

        __newindex = function (proxy, key, value)
            if key == "parent" then
                self:move(value);
            else 
                rawset(self, key, value);
            end
        end
    })

    self.proxy = proxy;
    return proxy;
end

function FsNode:__addToDrive()
    -- This method is encapsulated inside of classes extending FsNode.
end

function FsNode:__clone()
    local newNode = setmetatable({}, FsNode);
    
    newNode.displayName = self.displayName;
    newNode.simplifiedName = self.simplifiedName;
    newNode.parent = nil;
    newNode.path = nil;
    newNode.isReadOnly = false;

    if self.__children then
        newNode.__children = {};
        for childName, childNode in pairs(self.__children) do
            local copiedChild = childNode:copy();
            copiedChild.parent = newNode;
            newNode.__children[childName] = copiedChild;
        end
    end

    return newNode;
end

setmetatable(FsNode, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

return FsNode;


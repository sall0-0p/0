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

function FsNode.new(displayName, parent)
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

    if parent then
        parent.__children[displayName] = node;
    end

    return node;
end

-- Public methods
function FsNode:isDirectory()
    return false
end

function FsNode:move(newParent)
    -- FIXME: Add checks
    if not (newParent and newParent.className == "Directory") then
        error("newParent has to be a directory!");
    end

    local oldPath = self.path;
    if self.parent then
        self.parent:removeChild(self);
    end

    newParent:addChild(self);
    self.parent = newParent;
    self.path = self:__generatePath();
    self.readOnly = fs.isReadOnly(self.path);

    if oldPath then
        fs.move(oldPath, self.path);
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
    newNode:move(newParent);

    if newNode.path then
        fs.copy(self.path, newNode.path);
    end

    return newNode;
end

function FsNode:delete()
    if self.parent then
        -- self.parent.__children[self.displayName] = nil;
        self.parent:removeChild(self);
    end

    if self.path then
        fs.delete(self.path);
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
    
    self.parent:removeChild(self);
    self.displayName = newName;
    self.simplifiedName = self:__simplifyName();
    self.path = self:__generatePath();
    self.parent:addChild(self);

    fs.move(oldPath, self.path);

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


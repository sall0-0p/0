---@class FsNode

local FsNode = {};
FsNode.__parent = FsNode;

function FsNode.new(name, parent, isReadOnly)
    local node = setmetatable({}, FsNode);
    node.displayName = name;
    node.simplifiedName = node:__simplifyName();
    node.parent = parent;
    node.path = node:__generatePath();
    node.isReadOnly = fs.isReadOnly(node.path);

    return FsNode;
end

function FsNode:__generatePath()
    local ancestor = self;
    local ancestors = {};
    local result = "/"

    while ancestor.parent ~= nil do
        table.insert(ancestors, ancestor);
    end

    for i = 1, #ancestor do
        -- stack logic
        local lastItem = table.remove(ancestors);
        result = result .. "/" .. lastItem.simplifiedName;
    end
end

function FsNode:__simplifyName()
    local simplifiedName = self.displayName:gsub("%s", "_")
    simplifiedName = simplifiedName:gsub("[^%w_.-]", "")
    return simplifiedName
end

local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local ContentProvider = System.getContentProvider();
local Metadata = ContentProvider.get("UwU.FileSystem.Metadata.Metadata");

local DirectoryMetadata = {};
DirectoryMetadata.__index = DirectoryMetadata;

---@param directory File
function DirectoryMetadata.new(directory, permissions, custom, linkedTo)
    local metadata = setmetatable(Metadata(directory.displayName, permissions, custom), DirectoryMetadata);
    metadata.linkedTo = linkedTo or nil; -- if file is a symlink this property has to be set to respectable path.

    return metadata;
end

function DirectoryMetadata.fromTable(data)
    local metadata = setmetatable(Metadata(data[1], data[2], data[0]), DirectoryMetadata);
    metadata.linkedTo = data[6];
    metadata.defaultPermissions = data[3] or Metadata.DEFAULT_PERMISSIONS;

    return metadata;
end

function DirectoryMetadata:toTable()
    local function resolveDefaultPermissions() 
        if self.defaultPermissions == Metadata.DEFAULT_PERMISSIONS then
            return nil;
        else 
            return self.defaultPermissions;
        end
    end

    return {
        [1] = self.displayName;
        [2] = self.permissions;
        [3] = resolveDefaultPermissions();
        [6] = self.linkedTo;

        [0] = self.custom;
    }
end

setmetatable(DirectoryMetadata, {
    __index = Metadata;
    __call = function(cls, ...) 
        return cls.new(...);
    end
})

return DirectoryMetadata
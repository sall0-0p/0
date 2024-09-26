local ContentProvider = System.getContentProvider();
local Metadata = ContentProvider.get("UwU.FileSystem.Metadata.Metadata");

local FileMetadata = {};
FileMetadata.__index = FileMetadata;

---@param file File
function FileMetadata.new(file, permissions, custom, linkedTo)
    local metadata = setmetatable(Metadata(file.displayName, permissions, custom), FileMetadata);
    metadata.size = fs.getSize(file.path);
    metadata.linkedTo = linkedTo or nil; -- if file is a symlink this property has to be set to respectable path.

    return metadata;
end

function FileMetadata.fromTable(data)
    local metadata = setmetatable(Metadata(data[1], data[2], data[0]), FileMetadata);
    metadata.size = data[5];
    metadata.linkedTo = data[6];
    metadata.defaultPermissions = data[3] or Metadata.DEFAULT_PERMISSIONS;

    return metadata;
end

function FileMetadata:toTable()
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
        [5] = self.size;
        [6] = self.linkedTo;

        [0] = self.custom;
    }
end

setmetatable(FileMetadata, {
    __index = Metadata;
    __call = function(cls, ...) 
        return cls.new(...);
    end
})

return FileMetadata
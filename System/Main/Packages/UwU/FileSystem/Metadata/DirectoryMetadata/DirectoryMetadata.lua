local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local ContentProvider = System.getContentProvider();
local Metadata = ContentProvider.get("UwU.FileSystem.Metadata.Metadata");

local DirectoryMetadata = {};
DirectoryMetadata.__index = DirectoryMetadata;

local metadataManager;

local function generateProxy(object, path)
    local proxy = setmetatable({}, {
        __index = function(proxy, key)
            return object[key];
        end,
        
        __newindex = function (proxy, key, value)
            rawset(object, key, value);

            metadataManager.updateMeta(path, object);
        end
    })

    return proxy;
end

---@param directory File
function DirectoryMetadata.new(directory, permissions, custom, linkedTo)
    local metadata = setmetatable(Metadata(directory.displayName, permissions, custom), DirectoryMetadata);
    metadata.linkedTo = linkedTo or nil; -- if file is a symlink this property has to be set to respectable path.

    return generateProxy(metadata, directory.path);
end

function DirectoryMetadata.fromTable(data, path)
    local metadata = setmetatable(Metadata(data["1"], data["2"], data["0"]), DirectoryMetadata);
    metadata.linkedTo = data["6"];
    metadata.defaultPermissions = data["3"] or Metadata.DEFAULT_PERMISSIONS;
    metadata.permissions = data["2"] or {};
    metadata.custom = data["0"] or {};

    return generateProxy(metadata, path);
end

function DirectoryMetadata:toTable()
    local function resolveDefaultPermissions() 
        if self.defaultPermissions == Metadata.DEFAULT_PERMISSIONS then
            return nil;
        else 
            return self.defaultPermissions;
        end
    end

    local function resolveEmpty(value) 
        if next(value) == nil then
            return nil;
        else 
            return value;
        end
    end


    return {
        ["1"] = self.displayName;
        ["2"] = resolveEmpty(self.permissions);
        ["3"] = resolveDefaultPermissions();
        ["6"] = self.linkedTo;

        ["0"] = resolveEmpty(self.custom);
    }
end

setmetatable(DirectoryMetadata, {
    __index = Metadata;
    __call = function(cls, ...) 
        return cls.new(...);
    end
})

function DirectoryMetadata.init(mtdManager)
    metadataManager = mtdManager
    DirectoryMetadata["init"] = nil;
end

return DirectoryMetadata
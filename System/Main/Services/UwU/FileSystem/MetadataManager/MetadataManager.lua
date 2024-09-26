local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local ContentProvider = System.getContentProvider();
local FileMetadata = ContentProvider.get("UwU.FileSystem.Metadata.FileMetadata");
local DirectoryMetadata = ContentProvider.get("UwU.FileSystem.Metadata.DirectoryMetadata");

local MetadataManager = {};

local METADATA_SAVE_LOCATION = "/System/Config/fs_metadata.tbl";
local metadata = {};
local function init()
    local file = fs.open(METADATA_SAVE_LOCATION, "r");
    local metadataRaw = file.readAll();

    if metadataRaw ~= "" then
        metadata = textutils.unserialise(metadataRaw);
    end

    file.close();
end

function MetadataManager.buildMeta(object)
    -- if metadata already defined for this path;
    if metadata[object.path] then
        if object.className == "Directory" or object.className == "RootDirectory" then
            return DirectoryMetadata.fromTable(metadata[object.path]);
        elseif object.className == "File" then
            return FileMetadata.fromTable(metadata[object.path]);
        end
    -- if object is completely new, generate blank metadata;
    else 
        local newMeta
        if object.className == "Directory" or object.className == "RootDirectory" then
            newMeta = DirectoryMetadata.new(object, {}, {});
        elseif object.className == "File" then
            newMeta = FileMetadata.new(object, {}, {});
        end

        local rawMeta = fs.attributes(object.path);
        newMeta.created = rawMeta.created;
        newMeta.modified = rawMeta.modified;

        return newMeta;
    end
end

function MetadataManager.changeMeta(oldPath, newPath, data)
    metadata[oldPath] = nil;
    metadata[newPath] = data:toTable();
    local file = fs.open(METADATA_SAVE_LOCATION, "w");

    file.write(textutils.serialise(metadata));
    file.close();
end

function MetadataManager.updateMeta(object, data)
    metadata[object.path] = data:toTable();
    local file = fs.open(METADATA_SAVE_LOCATION, "w");

    file.write(textutils.serialise(metadata));
    file.close();
end

return setmetatable(MetadataManager, {
    __call = init;
});
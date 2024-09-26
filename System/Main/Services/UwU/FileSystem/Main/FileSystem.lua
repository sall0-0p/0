local ContentProvider = System:getContentProvider();
-- local MetadataManager = ContentProvider.get("UwU.FileSystem.MetadataManager");
local MetadataManager = require(".System.Main.Services.UwU.FileSystem.MetadataManager.MetadataManager");
local RootDirectory = ContentProvider.get("UwU.FileSystem.RootDirectory");
local Directory = ContentProvider.get("UwU.FileSystem.Directory");
local File = ContentProvider.get("UwU.FileSystem.File");

local FileSystem = {};
local root;

-- Public (static) methods.
function FileSystem.getRoot()
    return root;
end

-- FS Initialisation.

local function buildRecursively(parent)
    local items = fs.list(parent.path);

    for _, item in pairs(items) do
        if fs.isDir(parent.path .. "/" .. item) then
            -- print(item, "is directory")
            local directory = Directory(item, parent);
            buildRecursively(directory);
        else 
            -- print(item, "is file")
            File(item, parent);
        end
    end
end

local function build()
    MetadataManager();
    root = RootDirectory("");

    buildRecursively(root);
    print("Building is completed!");
end

setmetatable(FileSystem, {
    __call = function() 
        return build();
    end
})

return FileSystem;
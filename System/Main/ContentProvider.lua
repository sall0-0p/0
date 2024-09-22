local Map = require(".System.Main.Packages.UwU.Utils.Map.Map");
local Yaml = require(".System.Main.Packages.UwU.Utils.Modules.yaml");
local Logger = require(".System.Main.Packages.UwU.Utils.Logger.Logger");

local ContentProvider = {};
ContentProvider.__content = Map();

local types = Map.__fromTable({
    class = "class.yml",
    service = "service.yml",
})

function ContentProvider.register(configPath, packagePath)
    if not types:containsValue(fs.getName(configPath)) then
        Logger.warn("Tried to register %s, which is not suitable!", fs.getName(configPath));
        return
    end

    local parentFolder = fs.getDir(configPath);
    local file = fs.open(configPath, "r");
    local config = Yaml.eval(file.readAll());
    file.close();

    if config.lazy_loading then
        ContentProvider.__content:put(packagePath, {
            loaded = false;
            pathToInstance = "." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main;
            metadata = config;

            Logger.info("Registered package `%s` in LAZY mode;", packagePath)
        });
    else
        ContentProvider.__content:put(packagePath, {
            loaded = true;
            instance = require("." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main);
            metadata = config;

            Logger.info("Registered package `%s` in EAGER mode;", packagePath)
        });
    end
end

---Register content recursively. Will search for .yml config files. 
---@param path string
function ContentProvider.registerRecursive(path, packagePath)
    packagePath = packagePath or "";
    if fs.exists(path) then
        for _, item in pairs(fs.list(path)) do
            local itemPath = fs.combine(path, item);
            if string.find(item, ".yml") then
                ContentProvider.register(itemPath, packagePath);
            end

            if fs.isDir(itemPath) then
                local newPackagePath = packagePath .. "." .. item
                if string.sub(newPackagePath, 1, 1) == "." then
                    newPackagePath = string.sub(newPackagePath, 2, -1);
                end
                ContentProvider.registerRecursive(itemPath, newPackagePath);
            end
        end
    end
end

function ContentProvider.get(packageName)
    local package = ContentProvider.__content:get(packageName);
    assert(package, string.format("Package with name %s is not found", packageName));

    if package.loaded == true then
        return package.instance;
    else 
        package.instance = require(package.pathToInstance);
        package.pathToInstance = nil;
        package.loaded = true;
        ContentProvider.__content:replace(packageName, package);
        return package.instance;
    end
end



return ContentProvider;
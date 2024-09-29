local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

local Map = require(".System.Main.Packages.UwU.Utils.Map.Map");
local Yaml = require(".System.Main.Packages.UwU.Utils.Modules.yaml");
local Logger = require(".System.Main.Packages.UwU.Utils.Logger.Logger");

local ContentProvider = {};
ContentProvider.__content = Map();

local types = Map.__fromTable({
    class = "class.yml",
    service = "service.yml",
})

function ContentProvider.register(package)
    local metadata = package.metadata;
    local packagePath = package.packagePath;
    local path = package.path;

    if metadata.lazy_loading then
        ContentProvider.__content:put(packagePath, {
            loaded = false;
            pathToInstance = "." .. string.gsub(path, "/", ".") .. "." .. metadata.main;

            Logger.info("Registered package `%s` in LAZY mode;", packagePath)
        });
    else
        ContentProvider.__content:put(packagePath, {
            loaded = true;
            module = require("." .. string.gsub(path, "/", ".") .. "." .. metadata.main);


            Logger.info("Registered package `%s` in EAGER mode;", packagePath)
        });
    end
end

local function readConfig(path)
    local file = fs.open(path, "r");
    local config = Yaml.eval(file.readAll());
    file.close();

    return config;
end

local function buildListRecursive(path, packagePath, result)
    local result = result or {};

    packagePath = packagePath or "";
    if fs.exists(path) then
        for _, item in pairs(fs.list(path)) do
            local itemPath = fs.combine(path, item);
            if string.find(item, ".yml") then
                if not types:containsValue(item) then
                    Logger.warn("Tried to register %s, which is not suitable!", item);
                else 
                    local success, metadata = xpcall(function() 
                        return readConfig(fs.combine(path, item));
                    end, 

                    function(err) -- error handler
                        Logger.error("Error opening config %s", item);
                        Logger.error(err);
                    end)
    
                    if success and metadata then
                        table.insert(result, {
                            packagePath = packagePath; -- requesting path
                            path = path; -- path to folder with contents
                            metadata = metadata; -- metadata
                        });
                    end
                end
            end

            if fs.isDir(itemPath) then
                local newPackagePath = packagePath .. "." .. item
                if string.sub(newPackagePath, 1, 1) == "." then
                    newPackagePath = string.sub(newPackagePath, 2, -1);
                end
                buildListRecursive(itemPath, newPackagePath, result);
            end
        end
    end
    
    return result;
end

local function contains(list, value)
    for _, item in pairs(list) do
        if item == value then
            return true;
        end
    end

    return false;
end

function ContentProvider.build(path)
    local list = buildListRecursive(path);

    table.sort(list, function(a, b) 
        local aMeta = a.metadata
        local bMeta = b.metadata

        if aMeta.dependencies then
            if contains(aMeta.dependencies, bMeta.packagepath) then
                return true;
            end
        end

        return false;
    end)

    for _, package in pairs(list) do
        ContentProvider.register(package)
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
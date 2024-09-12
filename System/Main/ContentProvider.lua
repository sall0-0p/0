local Map = require(".System.Main.Packages.Utils.Map.Map");
local Yaml = require(".System.Main.Packages.Utils.Libraries.yaml");
local Logger = require(".System.Main.Packages.Utils.Logger.Logger");

local ContentProvider = {};
ContentProvider.__content = {};
ContentProvider.__content.classes = Map();
ContentProvider.__content.services = Map();

-- Functions

local function registerClass(configPath, packagePath)
    local parentFolder = fs.getDir(configPath);
    local file = fs.open(configPath, "r");
    local config = Yaml.eval(file.readAll());
    file.close();

    if config.lazy_loading then
        ContentProvider.__content.classes:put(packagePath, {
            loaded = false;
            pathToInstance = "." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main;
            metadata = config;
            Logger.info("Registered Class `%s` in LAZY mode;", packagePath)
        });
    else
        ContentProvider.__content.classes:put(packagePath, {
            loaded = true;
            instance = require("." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main);
            metadata = config;

            Logger.info("Registered Class `%s` in EAGER mode;", packagePath)
        });
    end
end

local function registerService(configPath, packagePath)
    local parentFolder = fs.getDir(configPath);
    local file = fs.open(configPath, "r");
    local config = Yaml.eval(file.readAll());
    file.close();

    if config.lazy_loading then
        ContentProvider.__content.services:put(packagePath, {
            loaded = false;
            pathToInstance = "." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main;
            metadata = config;

            Logger.info("Registered Service `%s` in LAZY mode;", packagePath)
        });
    else
        ContentProvider.__content.services:put(packagePath, {
            loaded = true;
            instance = require("." .. string.gsub(parentFolder, "/", ".") .. "." .. config.main);
            metadata = config;

            Logger.info("Registered Service `%s` in EAGER mode;", packagePath)
        });
    end
end

function ContentProvider.register(configPath, packagePath)
    if fs.getName(configPath) == "class.yml" then
        registerClass(configPath, packagePath);
    end

    if fs.getName(configPath) == "service.yml" then
        registerService(configPath, packagePath);
    end
end

---Register content recursively. Will search for .yml config files. 
---@param path string
function ContentProvider.registerRecursive(path, packagePath)
    packagePath = packagePath or "";
    print(packagePath);
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

---Get class by name, function is for system use. System classes are stored in `System/Main/Classes`
---@param className string
---@return table class
function ContentProvider.getClass(className)
    local class = ContentProvider.__content.classes:get(className);
    assert(class, string.format("Class with name %s does not exist!", className));

    if class.loaded == true then
        return class.instance;
    else 
        class.instance = require(class.pathToInstance);
        class.pathToInstance = nil;
        class.loaded = true;
        ContentProvider.__content.classes:replace(className, class);
        return class.instance;
    end
end


function ContentProvider.getService(serviceName)
    local service = ContentProvider.__content.services:get(serviceName);
    assert(service, string.format("Service with name %s does not exist!", serviceName));

    if service.loaded == true then
        return service.instance;
    else 
        service.instance = require(service.pathToInstance);
        service.pathToInstance = nil;
        service.loaded = true;
        ContentProvider.__content.services:replace(serviceName, service);
        return service.instance;
    end
end

return ContentProvider;
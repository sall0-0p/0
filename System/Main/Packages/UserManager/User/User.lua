local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");
local hasher = require(".System.Main.Packages.Utils.Modules.sha256");

local USER_CONFIG_FILE = "/System/Config/users.tbl";

--- @class User
--- @field id number
--- @field username string
--- @field salt string
--- @field hashedPassword string
local User = {}
User.__index = User;

-- Utilities
local function generateId()
    local configs = fs.list(USER_CONFIG_FOLDER);

    if #configs > 0 then
        for index, config in pairs(configs) do
            print(index, config);
            configs[index] = tonumber(table.pack(string.gsub(config, ".tbl", ""))[1]);
        end
    else 
        return 1;
    end

    return math.max(table.unpack(configs)) + 1;
end

function User.new(username, password)
    local user = setmetatable({}, User);
    
    user.id = generateId();
    user.username = username;
    user.salt = hasher.generate_salt(8);
    user.hashedPassword = hasher.generate_hash(user.salt .. password);

    return proxygen(user);
end

function User.fromData(data);
    local user = setmetatable({}, User);

    user.id = data.id;
    user.username = data.username;
    user.salt = data.salt;
    user.hashedPassword = data.hashedPassword;

    return proxygen(user);
end

setmetatable(User, {
    __call = function(cls, ...)
        return cls.new(...)
    end
});

return User;
local ContentProvider = System.getContentProvider();
local User = ContentProvider.get("UserManager.User");
local Group = ContentProvider.get("UserManager.Group");
local Map = ContentProvider.get("Utils.Map");

local USERS_FOLDER = "/Users/";
local USER_CONFIG_FILE = "/System/Config/users.tbl";

local UserManager = {};
local users = Map();

-- FIXME: Use custom file system in future.
local function saveAllUsers(users)
    local serializedUsers = textutils.serialise(users)

    local file = fs.open(USER_CONFIG_FILE, "w")
    file.write(serializedUsers)
    file.close()
end

-- FIXME: Use custom file system in future.
local function loadAllUsers()
    if fs.exists(USER_CONFIG_FILE) then
        local file = fs.open(USER_CONFIG_FILE, "r")
        local rawData = file.readAll()
        file.close()

        local users = textutils.unserialise(rawData)
        return users or {}
    end

    return {}
end

function UserManager.createUser(username, password, createHomeDir)
    local user = User(username, password);
    users[user.id] = user;

    if createHomeDir == nil or createHomeDir then
        fs.makeDir(USERS_FOLDER .. username)
    end
end

function UserManager.getUserById(id)
    
end

function UserManager.getUserByUsername(username)
    
end

function UserManager.deleteUser()
    
end

return UserManager;
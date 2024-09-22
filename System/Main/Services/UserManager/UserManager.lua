local ContentProvider = System.getContentProvider();
local User = ContentProvider.get("UserManager.User");
local Group = ContentProvider.get("UserManager.Group");
local GroupManager = ContentProvider.get("GroupManager");
local Map = ContentProvider.get("Utils.Map");

local USERS_FOLDER = "/Users/";
local USER_CONFIG_FILE = "/System/Config/users.tbl";

-- Misc functions

-- FIXME: Use custom file system in future.
local function saveAllUsers(users)
    local rawUsers = {};

    for id, user in users do
        rawUsers[id] = user:toTable();
    end

    local serializedUsers = textutils.serialise(rawUsers);
    local file = fs.open(USER_CONFIG_FILE, "w");
    file.write(serializedUsers);
    file.close();
end

-- FIXME: Use custom file system in future.
local function loadAllUsers()
    if fs.exists(USER_CONFIG_FILE) then
        local file = fs.open(USER_CONFIG_FILE, "r");
        local rawData = file.readAll();
        file.close();

        local usersRaw = textutils.unserialise(rawData);
        local users = Map();

        for id, data in pairs(usersRaw) do
            users[id] = User.fromData(data);
        end

        return users;
    end

    return Map();
end

local function generateId(users)
    local ids = {}
    for _, user in users do
        table.insert(ids, user.id);
    end

    return math.max(table.unpack(ids)) + 1
end

-- User manager

local UserManager = {};
local users;

function UserManager.createUser(username, password, createHomeDir)
    local user = User(generateId(users), username, password);
    users[user.id] = user;

    if createHomeDir == nil or createHomeDir then
        fs.makeDir(USERS_FOLDER .. username)
    end

    saveAllUsers(users);

    return user;
end

function UserManager.getUserById(id)
    return users[id];
end

function UserManager.getUserByUsername(username)
    for _, user in users do
        if user.username == username then
            return user;
        end
    end

    return nil;
end

function UserManager.deleteUser(id)
    if id == 1 then
        error("Cannot delete root user!");
    end

    local user = users[id];

    if not user then
        error("User does not exist!");
    end

    -- Remove user from all groups
    GroupManager.removeUserFromAllGroups(id);

    if fs.exists(USERS_FOLDER .. user.username) then
        fs.delete(USERS_FOLDER .. user.username);
    end

    users[id] = nil;
    saveAllUsers(users);
end

function UserManager.getUserGroups(userId)
    local userGroups = {};
    local allGroups = GroupManager.getAllGroups();

    for _, group in allGroups do
        if group:isMember(userId) then
            table.insert(userGroups, group);
        end
    end

    return userGroups;
end

users = loadAllUsers();
return UserManager;
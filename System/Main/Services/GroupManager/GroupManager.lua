local ContentProvider = System.getContentProvider();
local Group = ContentProvider.get("UserManager.Group");
local Map = ContentProvider.get("Utils.Map");

local GROUP_CONFIG_FILE = "/System/Config/groups.tbl";

-- Misc functions

local function saveAllGroups(groups)
    local rawGroups = {};

    for id, group in groups do
        rawGroups[id] = group:toTable();
    end

    local serializedGroups = textutils.serialize(rawGroups);
    local file = fs.open(GROUP_CONFIG_FILE, "w");
    file.write(serializedGroups);
    file.close();
end

local function loadAllGroups()
    if fs.exists(GROUP_CONFIG_FILE) then
        local file = fs.open(GROUP_CONFIG_FILE, "r");
        local rawData = file.readAll();
        file.close();

        local groupsRaw = textutils.unserialize(rawData);
        local groups = Map();

        for id, data in pairs(groupsRaw) do
            groups[id] = Group.fromData(data);
        end

        return groups;
    end

    return Map();
end

local function generateGroupId(groups)
    local ids = {}
    for id, _ in groups do
        table.insert(ids, id);
    end

    if #ids == 0 then
        return 1
    else
        return math.max(table.unpack(ids)) + 1
    end
end

local GroupManager = {};
local groups;

function GroupManager.createGroup(groupName)
    local id = generateGroupId(groups);
    local group = Group(id, groupName);
    groups[id] = group;
    saveAllGroups(groups);
    return group;
end

function GroupManager.getGroupById(id)
    return groups[id];
end

function GroupManager.getGroupByName(groupName)
    for _, group in groups do
        if group.groupName == groupName then
            return group;
        end
    end
    return nil;
end

function GroupManager.deleteGroup(id)
    local group = groups[id];
    if not group then
        error("Group does not exist!");
    end
    groups[id] = nil;
    saveAllGroups(groups);
end

function GroupManager.addUserToGroup(userId, groupId)
    local group = groups[groupId];
    if not group then
        error("Group does not exist!");
    end
    group:addUser(userId);
    saveAllGroups(groups);
end

function GroupManager.removeUserFromGroup(userId, groupId)
    local group = groups[groupId];
    if not group then
        error("Group does not exist!");
    end
    group:removeUser(userId);
    saveAllGroups(groups);
end

function GroupManager.removeUserFromAllGroups(userId)
    for _, group in groups do
        if group:isMember(userId) then
            group:removeUser(userId);
        end
    end
    saveAllGroups(groups);
end

function GroupManager.getAllGroups()
    return groups;
end



groups = loadAllGroups();
return GroupManager;

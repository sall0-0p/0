local ContentProvider = System.getContentProvider();
local GroupManager = ContentProvider.get("GroupManager");
local UserManager = ContentProvider.get("UserManager");

local tests = {}

-- Utility functions to clean up groups and users
local function cleanupGroup(groupId)
    if GroupManager.getGroupById(groupId) then
        GroupManager.deleteGroup(groupId)
    end
end

local function cleanupUser(userId)
    if UserManager.getUserById(userId) then
        UserManager.deleteUser(userId)
    end
end

-- Test creating a new group
function tests.createGroupTest()
    local groupName = "testgroup"
    local group = GroupManager.createGroup(groupName)

    local retrievedGroup = GroupManager.getGroupById(group.id)
    local result = retrievedGroup ~= nil and retrievedGroup.groupName == groupName

    -- Cleanup
    cleanupGroup(group.id)

    return result
end

-- Test deleting a group
function tests.deleteGroupTest()
    local groupName = "deletegroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.deleteGroup(group.id)
    local retrievedGroup = GroupManager.getGroupById(group.id)
    local result = retrievedGroup == nil

    return result
end

-- Test adding a user to a group
function tests.addUserToGroupTest()
    local username = "groupuser"
    local password = "grouppass"
    local user = UserManager.createUser(username, password, false)

    local groupName = "addusergroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.addUserToGroup(user.id, group.id)
    local isMember = group:isMember(user.id)

    -- Cleanup
    cleanupUser(user.id)
    cleanupGroup(group.id)

    return isMember
end

-- Test removing a user from a group
function tests.removeUserFromGroupTest()
    local username = "removeuser"
    local password = "removepass"
    local user = UserManager.createUser(username, password, false)

    local groupName = "removeusergroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.addUserToGroup(user.id, group.id)
    GroupManager.removeUserFromGroup(user.id, group.id)
    local isMember = group:isMember(user.id)

    -- Cleanup
    cleanupUser(user.id)
    cleanupGroup(group.id)

    return not isMember
end

-- Test getting a group by name
function tests.getGroupByNameTest()
    local groupName = "groupbyname"
    local group = GroupManager.createGroup(groupName)

    local retrievedGroup = GroupManager.getGroupByName(groupName)
    local result = retrievedGroup ~= nil and retrievedGroup.id == group.id

    -- Cleanup
    cleanupGroup(group.id)

    return result
end

-- Test removing a user from all groups upon deletion
function tests.userDeletionCleanupTest()
    local username = "cleanupuser"
    local password = "cleanuppass"
    local user = UserManager.createUser(username, password, false)

    local groupName = "cleanupgroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.addUserToGroup(user.id, group.id)
    UserManager.deleteUser(user.id)
    local isMember = group:isMember(user.id)

    -- Cleanup
    cleanupGroup(group.id)

    return not isMember
end

-- Test that groups can have multiple users
function tests.multipleUsersInGroupTest()
    local username1 = "multiuser1"
    local username2 = "multiuser2"
    local password = "multipass"

    local user1 = UserManager.createUser(username1, password, false)
    local user2 = UserManager.createUser(username2, password, false)

    local groupName = "multiplegroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.addUserToGroup(user1.id, group.id)
    GroupManager.addUserToGroup(user2.id, group.id)

    local isMember1 = group:isMember(user1.id)
    local isMember2 = group:isMember(user2.id)

    -- Cleanup
    cleanupUser(user1.id)
    cleanupUser(user2.id)
    cleanupGroup(group.id)

    return isMember1 and isMember2
end

-- Test that a user can belong to multiple groups
function tests.userInMultipleGroupsTest()
    local username = "multiplegroupsuser"
    local password = "multiplegrouppass"
    local user = UserManager.createUser(username, password, false)

    local groupName1 = "group1"
    local groupName2 = "group2"
    local group1 = GroupManager.createGroup(groupName1)
    local group2 = GroupManager.createGroup(groupName2)

    GroupManager.addUserToGroup(user.id, group1.id)
    GroupManager.addUserToGroup(user.id, group2.id)

    local isMemberGroup1 = group1:isMember(user.id)
    local isMemberGroup2 = group2:isMember(user.id)

    -- Cleanup
    cleanupUser(user.id)
    cleanupGroup(group1.id)
    cleanupGroup(group2.id)

    return isMemberGroup1 and isMemberGroup2
end

-- Test removing a group cleans up references
function tests.groupDeletionCleanupTest()
    local username = "groupdeleteuser"
    local password = "groupdeletepass"
    local user = UserManager.createUser(username, password, false)

    local groupName = "tobedeletedgroup"
    local group = GroupManager.createGroup(groupName)

    GroupManager.addUserToGroup(user.id, group.id)
    GroupManager.deleteGroup(group.id)

    local userGroups = UserManager.getUserGroups(user.id)
    local groupExists = GroupManager.getGroupById(group.id) ~= nil

    -- Cleanup
    cleanupUser(user.id)

    return not groupExists and #userGroups == 0
end

return {
    tests = tests;
    titles = {
        createGroupTest = "Test creating a new group";
        deleteGroupTest = "Test deleting a group";
        addUserToGroupTest = "Test adding a user to a group";
        removeUserFromGroupTest = "Test removing a user from a group";
        getGroupByNameTest = "Test retrieving a group by name";
        userDeletionCleanupTest = "Test user removal from groups upon deletion";
        multipleUsersInGroupTest = "Test groups with multiple users";
        userInMultipleGroupsTest = "Test user belonging to multiple groups";
        groupDeletionCleanupTest = "Test group deletion cleans up references";
    }
}

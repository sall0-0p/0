local ContentProvider = System.getContentProvider();
local UserManager = ContentProvider.get("UwU.UserManager");
local User = ContentProvider.get("UwU.UserManager.User");

local tests = {}

-- Utility function to clean up users
local function cleanupUser(userId)
    if UserManager.getUserById(userId) then
        UserManager.deleteUser(userId)
    end
end

-- Test creating a new user
function tests.createUserTest()
    local username = "testuser"
    local password = "testpass"
    local user = UserManager.createUser(username, password, false)

    local retrievedUser = UserManager.getUserById(user.id)
    local result = retrievedUser ~= nil and retrievedUser.username == username

    -- Cleanup
    cleanupUser(user.id)

    return result
end

-- Test deleting a user
function tests.deleteUserTest()
    local username = "deleteuser"
    local password = "deletepass"
    local user = UserManager.createUser(username, password, false)

    UserManager.deleteUser(user.id)
    local retrievedUser = UserManager.getUserById(user.id)
    local result = retrievedUser == nil

    return result
end

-- Test getting user by username
function tests.getUserByUsernameTest()
    local username = "userbyname"
    local password = "passbyname"
    local user = UserManager.createUser(username, password, false)

    local retrievedUser = UserManager.getUserByUsername(username)
    local result = retrievedUser ~= nil and retrievedUser.id == user.id

    -- Cleanup
    cleanupUser(user.id)

    return result
end

-- Test password validation
function tests.validatePasswordTest()
    local username = "passworduser"
    local password = "securepass"
    local user = UserManager.createUser(username, password, false)

    local isValid = user:validatePassword(password)
    local isInvalid = not user:validatePassword("wrongpass")
    local result = isValid and isInvalid

    -- Cleanup
    cleanupUser(user.id)

    return result
end

-- Test changing user password
function tests.changePasswordTest()
    local username = "changepassuser"
    local password = "oldpass"
    local newPassword = "newpass"
    local user = UserManager.createUser(username, password, false)

    user:changePassword(newPassword)
    local isValidOld = not user:validatePassword(password)
    local isValidNew = user:validatePassword(newPassword)
    local result = isValidOld and isValidNew

    -- Cleanup
    cleanupUser(user.id)

    return result
end

-- Test preventing deletion of root user
function tests.preventRootDeletionTest()
    local success = pcall(function()
        UserManager.deleteUser(1)
    end)
    return not success
end

-- Test generating unique user IDs
function tests.uniqueUserIdTest()
    local username1 = "user1"
    local username2 = "user2"
    local password = "pass"
    local user1 = UserManager.createUser(username1, password, false)
    local user2 = UserManager.createUser(username2, password, false)

    local result = user1.id ~= user2.id

    -- Cleanup
    cleanupUser(user1.id)
    cleanupUser(user2.id)

    return result
end

return {
    tests = tests;
    titles = {
        createUserTest = "Test creating a new user";
        deleteUserTest = "Test deleting a user";
        getUserByUsernameTest = "Test retrieving a user by username";
        validatePasswordTest = "Test user password validation";
        changePasswordTest = "Test changing a user's password";
        preventRootDeletionTest = "Test preventing deletion of the root user";
        uniqueUserIdTest = "Test unique user ID generation";
    }
}

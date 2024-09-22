local ContentProvider = System.getContentProvider();
local UserManager = ContentProvider.get("UwU.UserManager");

local user = UserManager.getUserByUsername(arg[1]);
if user then
    print("Id: " .. user.id);
    print("Username: " .. user.username);
else
    print("User not found!");
end


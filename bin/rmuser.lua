local ContentProvider = System.getContentProvider();
local UserManager = ContentProvider.get("UserManager");

local user = UserManager.getUserByUsername(arg[1]);
if user then
    UserManager.deleteUser(user.id);
else
    print("User does not exist!");
end


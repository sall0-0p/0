local ContentProvider = System.getContentProvider();
local UserManager = ContentProvider.get("UwU.UserManager");

UserManager.createUser(arg[1], arg[2]);

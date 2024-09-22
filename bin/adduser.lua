local ContentProvider = System.getContentProvider();
local UserManager = ContentProvider.get("UserManager");

UserManager.createUser(arg[1], arg[2]);

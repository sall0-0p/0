local ContentProvider = System.getContentProvider();
local User = ContentProvider.get("UserManager.User");

User.new(arg[1], arg[2]);

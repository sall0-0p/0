_G.System = require(".System.Main.Globals.System")

local ContentProvider = System.getContentProvider();
ContentProvider.registerRecursive("/System/Main/Packages");

local Logger = ContentProvider.getService("Utils.Logger");

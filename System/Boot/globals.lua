_G.System = require(".System.Main.Globals.System")

local ContentProvider = System.getContentProvider();
ContentProvider.registerRecursive("/System/Main/Classes");
ContentProvider.registerRecursive("/System/Main/Services");

local ProcessManager = ContentProvider.getService("ProcessManager");
local Logger = ContentProvider.getService("Logger");

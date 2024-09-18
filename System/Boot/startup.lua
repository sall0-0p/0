_G.System = require(".System.Main.Globals.System");
_G.Enum = require(".System.Main.Globals.Enum");

local ContentProvider = System.getContentProvider();
ContentProvider.registerRecursive("/System/Main/Packages");
ContentProvider.registerRecursive("/System/Main/Services");

shell.setPath(shell.path() .. ":/bin");
_G.System = require(".System.Main.Globals.System");
_G.Enum = require(".System.Main.Globals.Enum");

local ContentProvider = System.getContentProvider();
ContentProvider.build("/System/Main/Packages");
ContentProvider.build("/System/Main/Services");

shell.setPath(shell.path() .. ":/bin");
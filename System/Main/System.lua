local System = {};

-- ContentProvider
local ContentProvider = require ".System.Main.ContentProvider";
ContentProvider.registerRecursive("/System/Main/Classes");
ContentProvider.registerRecursive("/System/Main/Services");

System.__contentProvider = ContentProvider;

-- Methods
function System.getContentProvider()
    return System.__contentProvider;
end

return System;
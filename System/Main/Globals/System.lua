local System = {};

-- ContentProvider
local ContentProvider = require ".System.Main.ContentProvider";

System.__contentProvider = ContentProvider;
System.DEBUG = true;

-- Methods
function System.getContentProvider()
    return System.__contentProvider;
end

return System;
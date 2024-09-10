local System = {};

-- ContentProvider
local ContentProvider = require ".System.Main.ContentProvider";

System.__contentProvider = ContentProvider;

-- Methods
function System.getContentProvider()
    return System.__contentProvider;
end

return System;
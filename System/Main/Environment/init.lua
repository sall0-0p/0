local ContentProvider = System.getContentProvider();
local Logger = ContentProvider.get("UwU.Utils.Logger");
local EventManager = ContentProvider.get("UwU.EventManager");
local Event = ContentProvider.get("UwU.Events.Event");

return function(process)
    local Environment = {};

    Environment.os = {}
    Environment.table = {}
    Environment.keys = {}

    Environment.os.sleep = function(time) 
        process.currentThread:sleep(time);
        os.pullEvent("timer");
        process.currentThread.timer = nil;
    end

    Environment.print = function(...)
        print(...)
    end

    Environment.keys.getName = function(...) 
        return keys.getName(...);
    end

    Environment.os.pullEvent = function(filter) 
        return os.pullEvent(filter)
    end

    Environment.table.pack = function(...) 
        return table.pack(...);
    end

    Environment.table.unpack = function(...) 
        return table.unpack(...);
    end

    Environment.yield = function (...)
        coroutine.yield(...);
    end

    Environment.EventManager = EventManager;
    Environment.Logger = Logger;
    Environment.Event = Event;

    Environment.Enum = _G.Enum

    Environment.__pid = process.PID;
    Environment.__name = process.name;
    Environment.__process = process;

    return Environment;
end;
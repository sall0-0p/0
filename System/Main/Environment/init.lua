local ContentProvider = System.getContentProvider();
local Logger = ContentProvider.get("Utils.Logger");
local EventManager = ContentProvider.get("EventManager");
local Event = ContentProvider.get("Events.Event");

-- Environment.colors = colors;
-- Environment.colours = colours;
-- Environment.commands = commands;
-- Environment.disk = disk;
-- Environment.fs = fs;
-- Environment.gps = gps;
-- Environment.help = help;
-- Environment.http = http;
-- Environment.paintutils = paintutils;
-- Environment.peripheral = peripheral;
-- Environment.pocket = pocket;
-- Environment.rednet = rednet;
-- Environment.redstone = redstone;
-- Environment.settings = settings;
-- Environment.term = term;
-- Environment.textutils = textutils;
-- Environment.vector = vector;
-- Environment.os = os;

-- function Environment.getPID()
--     return Environment.__pid;
-- end

return function(process)
    local Environment = {};

    Environment.os = {}
    Environment.table = {}
    Environment.keys = {}

    Environment.os.sleep = function(time) 
        process:sleep(time);
        os.pullEvent("timer");
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

    return Environment;
end;
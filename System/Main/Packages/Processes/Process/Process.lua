local ContentProvider = System.getContentProvider();
local Logger = ContentProvider.get("Utils.Logger");
local Thread = ContentProvider.get("Processes.Thread");

local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");
local envgen = require(".System.Main.Environment");
local counter = 0;

---@class Process
---@field PID number
---@field name string
---@field priority number
---@field timer number
---@field environment table
---@field eventQueue table
---@field threads table
---@field currentThread number
local Process = {};
Process.__index = Process;

function Process.new(name, func)
    local process = setmetatable({}, Process);
    local proxy = proxygen(process);

    process.name = name;
    process.PID = counter + 1;
    process.priority = 10;
    process.eventQueue = {};
    process.environment = envgen(process);
    process.threads = {
        Thread(proxy, setfenv(func, process.environment));
    };
    process.currentThread = 0;

    counter = counter + 1;
    return proxy;
end

function Process:sleep(time)
    self.timer = os.startTimer(time);
end

-- getters
function Process:getName()
    return self.name;
end

function Process:getPID()
    return self.PID;
end

function Process:getCoroutine()
    return self.coroutine;
end

function Process:getTimer()
    return self.timer;
end

function Process:getEventQueue()
    return self.eventQueue;
end

function Process:getThreads()
    return self.threads;
end

function Process:getCurrentThread()
    return self.currentThread;
end

-- setters
function Process:setName(value)
    self.name = value;
end

function Process:setCoroutine(value)
    self.coroutine = value;
end

function Process:setTimer(value)
    self.timer = value;
end

function Process:setEventQueue(value)
    self.eventQueue = value;
end

function Process:setThreads(value)
    self.threads = value;
end

function Process:setCurrentThread(value)
    self.currentThread = value;
end

setmetatable(Process, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

return Process;

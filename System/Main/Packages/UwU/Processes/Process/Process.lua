local ContentProvider = System.getContentProvider();
local Logger = ContentProvider.get("UwU.Utils.Logger");
local Thread = ContentProvider.get("UwU.Processes.Thread");

local proxygen = require(".System.Main.Packages.UwU.Utils.Modules.proxygen");
local envgen = require(".System.Main.Environment");
local counter = 0;

---@class Process
---@field PID number
---@field parentPID number
---@field name string
---@field priority number
---@field timer number
---@field environment table
---@field eventQueue table
---@field threads table
---@field suspended boolean
---@field currentThread number
local Process = {};
Process.__index = Process;

function Process.new(name, func, parent)
    local process = setmetatable({}, Process);
    local proxy = proxygen(process);

    process.name = name;
    process.PID = counter + 1;
    process.parentPID = parent;
    process.priority = 10;
    process.eventQueue = {};
    process.environment = envgen(process);
    process.threads = {
        Thread(process, setfenv(func, process.environment));
    };
    process.suspended = false;
    process.currentThread = 0;

    counter = counter + 1;
    return proxy;
end

function Process:sleep(time)
    self.timer = os.startTimer(time);
end

function Process:addThread(func)
    local thread = Thread(self, setfenv(func, self.environment));
    self.threads[#self.threads+1] = thread;

    return thread;
end

-- getters
function Process:getName()
    return self.name;
end

function Process:getPID()
    return self.PID;
end

function Process:getParentPID()
    return self.parentPID;
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

function Process:getSuspended()
    return self.suspended;
end

function Process:getCurrentThread()
    return self.currentThread;
end

-- setters
function Process:setName(value)
    self.name = value;
end

function Process:setParentPID(value)
    self.parentPID = value;
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

function Process:setSuspended(value)
    self.suspended = value;
end

function Process:setCurrentThread(value)
    self.currentThread = value;
end

setmetatable(Process, {
    __call = function(cls, ...)
        return cls.new(...)
    end
});

return Process;
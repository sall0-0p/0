local ContentProvider = System.getContentProvider();
local Logger = ContentProvider.get("Utils.Logger");

local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");
local envgen = require(".System.Main.Environment");

local ContentProvider = System.getContentProvider();
local counter = 0;

---@class Process
---@field PID number
---@field name string
---@field coroutine thread
---@field priority number
---@field timer number
---@field eventQueue table
local Process = {};
Process.__index = Process;

function Process.new(name, func)
    local process = setmetatable({}, Process);

    process.name = name;
    process.PID = counter + 1;
    process.priority = 10;
    process.coroutine = coroutine.create(setfenv(func, envgen(process)));
    process.eventQueue = {};

    counter = counter + 1;
    return proxygen(process);
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

setmetatable(Process, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

return Process;

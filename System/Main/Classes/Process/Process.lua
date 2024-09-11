local ContentProvider = System.getContentProvider();
local PID = ContentProvider.getClass("PID");

---@class Process
---@field PID number
local Process = {};
Process.__index = Process;

function Process.new(name, func)
    local pid = PID.generateNext();
    local process = {};
end
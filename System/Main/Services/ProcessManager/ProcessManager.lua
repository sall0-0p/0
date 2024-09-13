local ContentProvider = System.getContentProvider();
local EventManager = ContentProvider.get("EventManager");
local Process = ContentProvider.get("Process");
local Logger = ContentProvider.get("Utils.Logger");

local ProcessManager = {};
local processes = {};

function ProcessManager.newProcess(name, func) 
    local process = Process(name, func);
    table.insert(processes, process);
end

function ProcessManager.getProcess(pid)
    for _, process in pairs(processes) do
        if process.PID == pid then
            return process;
        end
    end
end

function ProcessManager.getProcessList()
    return processes;
end

local function start()
    local tFilters = {};
    local eventData = { n = 0 };
    while #processes > 0 do
        if eventData[1] == "terminate" and System.DEBUG then return end

        for i, process in ipairs(processes) do
            if coroutine.status(process.coroutine) == "dead" then
                processes[i] = nil;
            else 
                if tFilters[process.coroutine] == nil or #process.eventQueue > 0 or (eventData[1] == "timer" and eventData[2] == process.timer) then
                    local resumeData
                    if #process.eventQueue > 0 then 
                        local event = process.eventQueue[#process.eventQueue];
                        process.eventQueue[#process.eventQueue] = nil;
                        resumeData = {true, tFilters[process.coroutine]};

                        if tFilters[process.coroutine] == event.eventType then
                            resumeData = table.pack(coroutine.resume(process.coroutine, event.eventType, table.unpack(event.body, 1, #event.body)));
                        end
                    else 
                        resumeData = table.pack(coroutine.resume(process.coroutine, table.unpack(eventData, 1, eventData.n)));
                    end
                    
                    if resumeData[1] == false then
                        Logger.fatal(string.format("Process %s stopped execution due to error!", process.PID));
                        Logger.fatal(resumeData[2]);
                    else 
                        tFilters[process.coroutine] = resumeData[2];
                    end
                end
            end
        end

        EventManager.init(ProcessManager);
        eventData = EventManager.waitForEvents();
    end

    Logger.fatal("All processes died, system crashed!");
end

setmetatable(ProcessManager, {
    __call = start;
})

return ProcessManager;
local ContentProvider = System.getContentProvider();
local EventManager = ContentProvider.get("EventManager");
local Process = ContentProvider.get("Processes.Process");
local Thread = ContentProvider.get("Processes.Thread");
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

function ProcessManager.killProcess()
    
end

local function start()
    local eventData = { n = 0 };
    while #processes > 0 do
        if eventData[1] == "terminate" and System.DEBUG then return end

        for processIndex, process in ipairs(processes) do
            for threadIndex, thread in ipairs(process.threads) do
                if coroutine.status(thread.coroutine) ~= "dead" then
                    if thread.filter == nil or #process.eventQueue > 0 or (eventData[1] == "timer" and eventData[2] == thread.timer) then
                        local resumeData
                        process.currentThread = thread;
                        if #process.eventQueue > 0 then
                            local event = process.eventQueue[#process.eventQueue];
                            
                            if thread.filter == event.eventType then
                                resumeData = table.pack(coroutine.resume(thread.coroutine, event.eventType, table.unpack(event.body, 1, #event.body)));
                            else 
                                resumeData = {true, thread.filter};
                            end

                            if threadIndex == #process.threads then
                                process.eventQueue[#process.eventQueue] = nil;
                            end
                        else 
                            resumeData = table.pack(coroutine.resume(thread.coroutine, table.unpack(eventData, 1, eventData.n)));
                        end

                        if resumeData[1] == false then
                            Logger.fatal(string.format("Process %s stopped execution due to error!", process.PID));
                            Logger.fatal(resumeData[2]);
                        else 
                            thread.filter = resumeData[2];
                        end

                        process.currentThread = 0;
                    end
                else 
                    if threadIndex == 1 then
                        -- This thread is the main thread of process, indicating that process have crashed.
                        -- TODO: Add optional cleanup call to all threads.
                        processes[processIndex] = nil;
                    else 
                        -- Notify process that thread have finished its task or have crashed.
                        -- TODO: Come up with actual notification for later.
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
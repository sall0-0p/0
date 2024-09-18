local ContentProvider = System.getContentProvider();
local EventManager = ContentProvider.get("EventManager");
local Process = ContentProvider.get("Processes.Process");
local Event = ContentProvider.get("Events.Event");
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
    EventManager.init(ProcessManager);
    local eventData = { n = 0 };
    while #processes > 0 do
        if eventData[1] == "terminate" and System.DEBUG then processes = {} return end

        for processIndex, process in ipairs(processes) do
            for threadIndex, thread in ipairs(process.threads) do
                -- Remove process/thread from process management
                local function removeProcess(exitCode) 
                    if threadIndex == 1 then
                        -- This thread is the main thread of process, indicating that process have crashed.
                        Logger.info("Process %s stopped its execution.", process.PID);
                        if process.parentPid then
                            EventManager.sendToProcess(process.PID, Event(Enum.Signal.SIGCHLD, { exitCode, process.PID }));
                        end
                        process.threads[1] = nil;
                        processes[processIndex] = nil;
                    else 
                        -- Notify process that thread have finished its task or have crashed.
                        Logger.info("Thread %s in process %s stopped its execution.", threadIndex, process.PID);
                        EventManager.sendToSelf(process.PID, Event(Enum.Signal.SIGTHRD, { exitCode, threadIndex }));
                        process.threads[threadIndex] = nil;
                    end
                end

                local resumeData = {true, thread.filter};
                local timerBypass = false;

                if coroutine.status(thread.coroutine) ~= "dead" then
                    if thread.filter == nil or #process.eventQueue > 0 then
                        process.currentThread = thread;
                        if #process.eventQueue > 0 then
                            for _, event in ipairs(process.eventQueue) do

                                -- Received termination signal, closing the program.
                                if event.eventType == Enum.Signal.SIGKILL then
                                    if threadIndex == 1 then
                                        Logger.warn("Process %s (%s) was terminated using SIGKILL signal!", process.PID, process.name);
                                    end
                                    
                                    --FIXME: Not handled in logic, hardcoded values, to be added into documentation
                                    removeProcess(130);
                                end

                                -- Received termination signals with cleanup call.
                                if event.eventType == Enum.Signal.SIGTERM or event.eventType == Enum.Signal.SIGHUP then
                                    if threadIndex == 1 then
                                        Logger.warn("Process %s (%s) was terminated using SIGTERM signal!", process.PID, process.name);
                                    end
                                    
                                    --FIXME: Not handled in logic, hardcoded values, to be added into documentation
                                    removeProcess(129);
                                end

                                if event.eventType == Enum.Signal.SIGCONT then
                                    Logger.info("Process %s was continued.", process.PID);
                                    process.suspended = false;

                                    if thread.timer then
                                        timerBypass = true;
                                    end
                                end

                                if event.eventType == Enum.Signal.SIGSTOP or event.eventType == Enum.Signal.SIGSTP then
                                    Logger.info("Process %s was stopped.", process.PID);
                                    process.suspended = true;
                                end
                                
                                if thread.filter == event.eventType and not process.suspended or timerBypass then
                                    resumeData = table.pack(coroutine.resume(thread.coroutine, event.eventType, table.unpack(event.body, 1, #event.body)));
                                end
                            end
                        else 
                            if not process.suspended then
                                resumeData = table.pack(coroutine.resume(thread.coroutine, table.unpack(eventData, 1, eventData.n)));
                            end
                        end

                        if resumeData[1] == false then
                            -- Program has errored
                            Logger.fatal(string.format("Process %s stopped execution due to error!", process.PID));
                            Logger.fatal(resumeData[2]);
                            Logger.traceback(thread.coroutine);
                            thread.exitCode = 1;
                        else 
                            thread.filter = resumeData[2];
                        end

                        process.currentThread = 0;
                    end
                end

                if coroutine.status(thread.coroutine) == "dead" then
                    -- Logger.warn("Thread %s from process %s is dead.", threadIndex, process.PID);
                    removeProcess(thread.exitCode or 0);
                end
            end

            process.eventQueue = {};
        end

        if #processes > 0 then
            eventData = EventManager.waitForEvents();
        end
    end

    Logger.fatal("All processes died, system crashed!");
    error("All processes died, system crashed!")
end

setmetatable(ProcessManager, {
    __call = start;
})

return ProcessManager;
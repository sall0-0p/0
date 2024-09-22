local ContentProvider = System.getContentProvider();
local Map = ContentProvider.get("UwU.Utils.Map");
local Event = ContentProvider.get("UwU.Events.Event");
local Logger = ContentProvider.get("UwU.Utils.Logger");
local EventConnection = ContentProvider.get("UwU.Events.EventConnection");

local EventManager = {};

local ProcessManager;
local listeners = Map();
local listening = false;
local eventQueue = {};

function EventManager.init(processManager)
    ProcessManager = processManager;
end

local function secureEventPath(EventType)
    if not listeners:get(EventType) then
        listeners:put(EventType, {});
    end
end

local function secureProcessPath(EventType, destinationPid)
    secureEventPath(EventType);

    if not listeners:get(EventType)[destinationPid] then
        listeners:get(EventType)[destinationPid] = {}
    end
end

local function fireListeners(Event, destinationPid)
    if destinationPid == "*" then
        secureEventPath(Event.eventType);
        local eventCallbacks = listeners:get(Event.eventType)
        for _, processCallbacks in pairs(eventCallbacks) do
            for _, callback in pairs(processCallbacks) do
                callback(table.unpack(Event.body));
            end
        end
    elseif type(destinationPid) == "number" then
        secureProcessPath(Event.eventType, destinationPid)
        local processCallbacks = listeners:get(Event.eventType)[destinationPid];
        for _, callback in pairs(processCallbacks) do
            callback(table.unpack(Event.body));
        end
    end
end

local function processEvent(eventData)
    if eventData[1] ~= "custom" and eventData[1] ~= "timer" then
        EventManager.broadcastToAll(0, Event(eventData[1], table.pack(table.unpack(eventData, 2, #eventData))));
        listening = false;
        return eventData;
    elseif eventData[1] == "timer" then
        for _, process in ipairs(ProcessManager.getProcessList()) do
            for threadIndex, thread in ipairs(process.threads) do
                if thread.timer == eventData[2] then
                    EventManager.sendToProcess(0, Event(eventData[1], table.pack(table.unpack(eventData, 2, #eventData))), process.PID);
                end
            end
        end
        listening = false;
        return eventData;
    else 
        return EventManager.waitForEvents();
    end
end

function EventManager.getListeners()
    return listeners;
end

function EventManager.registerListener(senderPid, EventType, listener)
    if EventType == Enum.Signal.SIGKILL then
        error("You are not allowed to register listener for SIGKILL");
    end

    if EventType == Enum.Signal.SIGSTOP then
        error("You are not allowed to register listener for SIGSTOP");
    end

    local index = #listeners + 1
    secureProcessPath(EventType, senderPid)

    table.insert(listeners:get(EventType)[senderPid], index, listener);

    return EventConnection(function() 
        listeners:get(EventType)[senderPid][index] = nil;
    end)
end

function EventManager.sendToProcess(senderPID, Event, destinationPid)
    Event.sender = senderPID;

    -- TODO: Add permission check here
    local destinationProcess = ProcessManager.getProcess(destinationPid);
    if destinationProcess then
        table.insert(destinationProcess.eventQueue, Event);
    end

    if not listening then
        table.insert(eventQueue, Event);
    end

    fireListeners(Event, destinationPid);
end

function EventManager.sendToSelf(senderPid, Event)
    EventManager.sendToProcess(senderPid, Event, senderPid);
end

function EventManager.broadcastToAll(senderPID, Event)
    Event.sender = senderPID;

    -- TODO: Add permission check here for root!
    for _, process in pairs(ProcessManager.getProcessList()) do
        table.insert(process.eventQueue, Event);
    end

    if not listening then
        table.insert(eventQueue, Event);
    end

    fireListeners(Event, "*");
end

function EventManager.waitForEvents()
    for index, event in ipairs(eventQueue) do
        eventQueue[index] = nil;
        return table.pack(event.eventType, table.unpack(event.body));
    end

    listening = true;
    local eventData = table.pack(os.pullEventRaw());

    return processEvent(eventData);
end

return EventManager;

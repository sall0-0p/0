local ContentProvider = System.getContentProvider();
local Map = ContentProvider.get("Utils.Map");
local Event = ContentProvider.get("Events.Event");
local Logger = ContentProvider.get("Utils.Logger");
local EventConnection = ContentProvider.get("Events.EventConnection");

local EventManager = {};

local ProcessManager;
local listeners = Map();

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

function EventManager.registerListener(senderPid, EventType, listener)
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

    fireListeners(Event, "*");
end

function EventManager.waitForEvents()
    local eventData = table.pack(os.pullEventRaw());

    if eventData[1] ~= "custom" and eventData[1] ~= "timer" then
        EventManager.broadcastToAll(0, Event(eventData[1], table.pack(table.unpack(eventData, 2, #eventData))));
        return eventData;
    elseif eventData[1] == "timer" then
        return eventData;
    else 
        return EventManager.waitForEvents();
    end
end

return EventManager;

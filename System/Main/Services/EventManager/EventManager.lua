local ContentProvider = System.getContentProvider();
local Map = ContentProvider.get("Utils.Map");
local Event = ContentProvider.get("Events.Event");
local Logger = ContentProvider.get("Utils.Logger");
local EventConnection = ContentProvider.get("Events.EventConnection");

local EventManager = {};

local ProcessManager;
local callbacks = Map();

function EventManager.init(processManager)
    ProcessManager = processManager;
end

local function secureEventPath(EventType)
    if not callbacks:get(EventType) then
        callbacks:put(EventType, {});
    end
end

local function secureProcessPath(EventType, destinationPid)
    secureEventPath(EventType);

    if not callbacks:get(EventType)[destinationPid] then
        callbacks:get(EventType)[destinationPid] = {}
    end
end

local function fire(Event, destinationPid)
    if destinationPid == "*" then
        secureEventPath(Event.eventType);
        local eventCallbacks = callbacks:get(Event.eventType)
        for _, processCallbacks in pairs(eventCallbacks) do
            for _, callback in pairs(processCallbacks) do
                callback(table.unpack(Event.body));
            end
        end
    elseif type(destinationPid) == "number" then
        secureProcessPath(Event.eventType, destinationPid)
        local processCallbacks = callbacks:get(Event.eventType)[destinationPid];
        for _, callback in pairs(processCallbacks) do
            callback(table.unpack(Event.body));
        end
    end
end

function EventManager.connect(senderPid, EventType, callback)
    local index = #callbacks + 1
    secureProcessPath(EventType, senderPid)

    table.insert(callbacks:get(EventType)[senderPid], index, callback);

    return EventConnection(function() 
        callbacks:get(EventType)[senderPid][index] = nil;
    end)
end

function EventManager.send(senderPID, Event, destinationPid)
    Event.sender = senderPID;

    -- TODO: Add permission check here
    local destinationProcess = ProcessManager.getProcess(destinationPid);
    if destinationProcess then
        table.insert(destinationProcess.eventQueue, Event);
    end

    fire(Event, destinationPid);
end

function EventManager.broadcast(senderPID, Event)
    Event.sender = senderPID;
    -- TODO: Add permission check here for root!
    for _, process in pairs(ProcessManager.getProcessList()) do
        table.insert(process.eventQueue, Event);
    end

    fire(Event, "*");
end

function EventManager.waitForEvents()
    local eventData = table.pack(os.pullEventRaw());

    if eventData[1] ~= "custom" and eventData[1] ~= "timer" then
        EventManager.broadcast(0, Event(eventData[1], table.pack(table.unpack(eventData, 2, #eventData))));
        return eventData;
    elseif eventData[1] == "timer" then
        return eventData;
    else 
        return EventManager.waitForEvents();
    end
end

return EventManager;

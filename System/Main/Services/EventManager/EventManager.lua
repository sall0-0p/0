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
    Logger.trace("Securing path for EventType: %s, Destination PID: %s", EventType, destinationPid)
    secureEventPath(EventType);

    if not callbacks:get(EventType)[destinationPid] then
        callbacks:get(EventType)[destinationPid] = {}
    end
end

local function fire(Event, destinationPid)
    Logger.trace("Firing event of type: %s to destination PID: %s", Event.eventType, destinationPid)
    
    if destinationPid == "*" then
        secureEventPath(Event.eventType);
        local eventCallbacks = callbacks:get(Event.eventType)
        Logger.trace("Broadcasting to all PIDs")
        for _, processCallbacks in pairs(eventCallbacks) do
            for _, callback in pairs(processCallbacks) do
                Logger.trace("Executing callback with event body: %s", table.concat(Event.body, ", "))
                callback(table.unpack(Event.body));
            end
        end
    elseif type(destinationPid) == "number" then
        secureProcessPath(Event.eventType, destinationPid)
        Logger.trace("Sending event to specific PID: %s", destinationPid)
        local processCallbacks = callbacks:get(Event.eventType)[destinationPid];
        for _, callback in pairs(processCallbacks) do
            Logger.trace("Executing callback with event body: %s", table.concat(Event.body, ", "))
            callback(table.unpack(Event.body));
        end
    end
end

function EventManager.connect(senderPid, EventType, callback)
    Logger.trace("Connecting event of type: %s for sender PID: %s", EventType, senderPid)
    local index = #callbacks + 1
    secureProcessPath(EventType, senderPid)

    table.insert(callbacks:get(EventType)[senderPid], index, callback);

    return EventConnection(function() 
        Logger.trace("Disconnecting event of type:", EventType, "for sender PID:", senderPid)
        callbacks:get(EventType)[senderPid][index] = nil;
    end)
end

function EventManager.send(senderPID, Event, destinationPid)
    Logger.trace("Sending event from PID:", senderPID, "to destination PID:", destinationPid)
    Event.sender = senderPID;

    -- TODO: Add permission check here
    local destinationProcess = ProcessManager.getProcess(destinationPid);
    if destinationProcess then
        Logger.trace("Appending event to destination process event queue")
        table.insert(destinationProcess.eventQueue, Event);
    end

    fire(Event, destinationPid);
end

function EventManager.broadcast(senderPID, Event)
    Logger.trace("Broadcasting event from PID: %s", senderPID)
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
        Logger.trace("System event detected: %s", eventData[1])
        EventManager.broadcast(0, Event(eventData[1], table.pack(table.unpack(eventData, 2, #eventData))));
        return eventData;
    elseif eventData[1] == "timer" then
        return eventData;
    else 
        Logger.trace("Custom event detected, waiting for next event")
        return EventManager.waitForEvents();
    end
end

return EventManager;

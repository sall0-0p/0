---@diagnostic disable: undefined-field, undefined-global
local ContentProvider = System.getContentProvider();
local ProcessManager = ContentProvider.get("UwU.ProcessManager");

local function listenForKeys()
    while true do
        local eventData = table.pack(os.pullEvent(Enum.EventType.KeyUp));
        print("You have pressed key: " .. keys.getName(eventData[2]));

        if keys.getName(eventData[2]) == "rightAlt" then
            print("Caught termination button, sending event!");
            EventManager.broadcastToAll(__pid, Event(Enum.Signal.SIGKILL));
        end
    end
end

local function listenForMouse()
    while true do
        local eventData = table.pack(os.pullEvent(Enum.EventType.MouseButtonDown));
        print("You have clicked button: " .. eventData[2] .. " at x: " .. eventData[3] .. " and y: " .. eventData[4]);
    end
end

local function countToThree()
    for i=1, 5 do
        print(i);
        os.sleep(1);
    end
end

ProcessManager.newProcess("My event handler", function() -- 1
    __process:addThread(listenForKeys);
    __process:addThread(listenForMouse);

    EventManager.registerListener(__pid, Enum.Signal.SIGTERM, function() 
        print("Bye!");
    end);

    EventManager.registerListener(__pid, Enum.Signal.SIGTHRD, function(exitCode, threadId) 
        print("Thread " .. threadId ..  " stopped its execution w/ exit code: " .. exitCode);
    end)

    EventManager.registerListener(__pid, Enum.Signal.SIGSTP, function() 
        print("Getting stopped!");
    end)

    __process:addThread(countToThree);

    while true do 
        yield();
    end
end)

ProcessManager.newProcess("Flow Controller 3000", function()
    while true do
        local eventData = table.pack(os.pullEvent(Enum.EventType.KeyUp));

        if keys.getName(eventData[2]) == "rightAlt" then
            print("Caught termination button, sending event!");
            EventManager.broadcastToAll(__pid, Event(Enum.Signal.SIGKILL));
        end

        if keys.getName(eventData[2]) == "minus" then
            EventManager.sendToProcess(__pid, Event(Enum.Signal.SIGSTP), 1);
        end

        if keys.getName(eventData[2]) == "equals" then
            EventManager.sendToProcess(__pid, Event(Enum.Signal.SIGCONT), 1);
        end
    end
end)

ProcessManager();

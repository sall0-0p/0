local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");

--- @class Event
--- @field eventType string
--- @field timestamp number
--- @field body any;
local Event = {};
Event.__index = Event;

function Event.new(eventType, body)
    local event = setmetatable({}, Event);
    event.eventType = eventType;
    event.body = body;

    return proxygen(event);
end

-- getters
function Event:getEventType()
    return self.eventType;
end

function Event:getBody()
    return self.body;
end

function Event:getSender()
    return self.sender;
end

-- setters
function Event:setSender(value)
    self.sender = value;
end

setmetatable(Event, {
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return Event;

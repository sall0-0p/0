local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");

--- @class EventConnection
--- @field __disconnectFunction function
--- @field body any;
local EventConnection = {};
EventConnection.__index = EventConnection;

function EventConnection.new(disconnectFunction)
    local event = setmetatable({}, EventConnection);
    event.__disconnectFunction = disconnectFunction;

    return proxygen(event);
end

function EventConnection:Disconnect(...)
    return EventConnection.__disconnectFunction(...);
end

-- getters
setmetatable(EventConnection, {
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return EventConnection;

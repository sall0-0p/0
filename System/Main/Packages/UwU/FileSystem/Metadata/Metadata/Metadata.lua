local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

--- @class Metadata
--- @field displayName string
--- @field permissions table
--- @field defaultPermissions table
--- @field created number
--- @field modified number
--- @field custom table

local Metadata = {};
Metadata.__index = Metadata;

local DEFAULT_PERMISSIONS = {
    r = false;
    w = false;
    e = false;
}

function Metadata.new(name, permissions, custom)
    local metadata = setmetatable({}, Metadata);
    metadata.displayName = name;
    metadata.permissions = permissions or {};
    metadata.defaultPermissions = DEFAULT_PERMISSIONS;
    metadata.custom = custom or {};

    ---@diagnostic disable-next-line: param-type-mismatch
    metadata.created = os.time(os.date("!*t"));
    ---@diagnostic disable-next-line: param-type-mismatch
    metadata.modified = os.time(os.date("!*t"));

    return metadata;
end

Metadata.DEFAULT_PERMISSIONS = DEFAULT_PERMISSIONS;
setmetatable(Metadata, {
    __call = function(cls, ...) 
        return cls.new(...);
    end
})

return Metadata
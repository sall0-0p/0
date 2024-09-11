-- TODO: Implement values() method
-- TODO: Implement keys() method
-- TODO: Add more assert methods

local function formatValue(tbl, v)
    if type(v) == "function" then
        return "function()"
    else 
        return v;
    end
end

local function debugPrint(tbl)
    for k, v in pairs(tbl) do
        print(string.format("%s - %s"), k, formatValue(tbl, v));
    end
end

--- @class Map
--- @field className string
local Map = {};
Map.__index = Map;

--- Blank constructor for a `Map` Class. Outputs empty `Map`.
--- @return Map returns
function Map.new()
    local proxy = {};
    local map = setmetatable({}, Map);
    map.__content = {};
    map.className = "Map";

    setmetatable(proxy, {
        __index = function(obj, key) 
            if rawget(map, key) then
                return rawget(map, key);
            elseif rawget(Map, key) then
                return rawget(Map, key)
            else
                return rawget(rawget(map, "__content"), key);
            end
        end,

        __newindex = function(obj, key, value)
            if rawget(map, key) then
               rawset(map, key, value)
            else 
                rawset(rawget(map, "__content"), key, value)
            end
        end,

        __call = function(_, _, key) 
            return next(map.__content, key);
        end
    })

    return proxy;
end

--- Constructor for a `Map` Class. Takes table (as disctionary).
--- @param input table
--- @return Map returns
function Map.fromTable(input)
    local map = Map();
    map.__content = input;

    return map;
end

function Map:clear()
    self.__content = {};
end

--- Attempts to compute a mapping for the specified key and its current mapped value (or nil if there is no current mapping).
--- @param key any
--- @param remappingFunction function accepts arguments `key, value`, returns new value
--- @return any value that was mapped to the key as result of `mappingFunction(key, value)` 
function Map:compute(key, remappingFunction)
    assert(key ~= nil, "Key cannot be nil!");
    assert(remappingFunction ~= nil, "Remapping function cannot be nil!");

    local value = remappingFunction(key, self.__content[key]);
    self.__content[key] = value;

    return value;
end

--- If the specified key is not already associated with a value (or is mapped to nil), attempts to compute its value using the given mapping function and enters it into this map unless nil.
--- @param key any
--- @param remappingFunction function accepts arguments `key`, returns new value
--- @return any value that was mapped to the key as result of `mappingFunction(key)` 
function Map:computeIfAbsent(key, remappingFunction)
    assert(key ~= nil, "Key cannot be nil!");
    assert(remappingFunction ~= nil, "Remapping function cannot be nil!");

    local value;
    if self.__content[key] == nil then
        value = remappingFunction(key);
        self.__content[key] = value;
    end
    
    return value;
end

--- If the value for the specified key is present and non-nil, attempts to compute a new mapping given the key and its current mapped value.
--- @param key any
--- @param remappingFunction function accepts arguments `key, value`, returns new value
--- @return any value that was mapped to the key as result of `mappingFunction(key, value)` 
function Map:computeIfPresent(key, remappingFunction)
    assert(key ~= nil, "Key cannot be nil!");
    assert(remappingFunction ~= nil, "Remapping function cannot be nil!");

    local value;
    if self.__content[key] ~= nil then
        value = remappingFunction(key, self.__content[key]);
        self.__content[key] = value;
    end
    
    return value;
end

--- Returns true if this map contains a mapping for the specified key.
--- @param key any
--- @return boolean 
function Map:containsKey(key)
    assert(key ~= nil, "Key cannot be nil!");

    return self.__content[key] ~= nil;
end

--- Returns true if this map maps one or more keys to the specified value.
--- @param value any
--- @return boolean 
function Map:containsValue(value)
    assert(value ~= nil, "Value cannot be nil!");

    for _, v in pairs(self.__content) do
        if v == value then
            return true;
        end
    end

    return false;
end

--- Returns `true` if this map has identical set of keys and values as map provided in `map`
--- @param map Map
--- @return boolean
function Map:equals(map)
    assert(map ~= nil, "Map cannot be nil!");
    assert(map.className == "Map", "Map provided has to belong to the class Map");

    for k, v in pairs(self.__content) do
        if map:get(k) ~= v then
            return false;
        end
    end

    return true;
end

--- Performs the given action for each entry in this map until all entries have been processed or the action throws an exception
--- @param action function
function Map:forEach(action)
    for k, v in pairs(self.__content) do
        action(k, v);
    end
end

--- Returns the value to which the specified key is mapped, or nil if this map contains no mapping for the key.
--- @param key any
--- @return any
function Map:get(key)
    return self.__content[key];
end

--- Returns true if this map contains no key-value mappings.
--- @return boolean
function Map:isEmpty()
    return (self:size() == 0);
end

--- Associates the specified value with the specified key in this map.
--- @param key any
--- @param value any
function Map:put(key, value)
    self.__content[key] = value;
end

--- Copies all of the mappings from the specified map to this map.
--- @param map Map
function Map:putAll(map)
    map:forEach(function(key, value) 
        self.__content[key] = value;
    end)
end

--- If the specified key is not already associated with a value (or is mapped to null) associates it with the given value and returns null, else returns the current value.
--- @param key any
--- @param value any
function Map:putIfAbsent(key, value)
    if self.__content[key] == nil then
        self.__content[key] = value;
        return value;
    end

    return nil;
end 

--- Removes the mapping for a key from this map if it is present, if so - returns previous held value.
--- @param key any
--- @return any
function Map:remove(key)
    if self.__content[key] ~= nil then
        local value = self.__content[key];
        self.__content[key] = nil;
        return value;
    end

    return nil;
end

--- Removes the entry for the specified key only if it is currently mapped to the specified value. Returns boolean indicating wether value was removed or not.
--- @param key any
--- @param value any
--- @return boolean
function Map:removeSpecificValue(key, value)
    if self.__content[key] == value then
        
        self.__content[key] = nil;
        return true;
    end

    return false;
end

--- Replaces the entry for the specified key only if currently mapped to the specified value. Returns boolean indicating wether value was removed or not.
--- @param key any
--- @param value any
--- @return boolean
function Map:replace(key, value)
    if self.__content[key] ~= nil then
        self.__content[key] = value;
        return true;
    end

    return false;
end

--- Replaces each entry's value with the result of invoking the given `function(K,V)` on that entry until all entries have been processed or function errored.
--- @param func function
function Map:replaceAll(func)
    for k, v in pairs(self.__content) do
        self.__content[k] = func(k, v);
    end
end

--- Returns the number of key-value mappings in this map.
--- @return number
function Map:size()
    local count = 0
    for _, _ in pairs(self.__content) do
        count = count + 1;
    end

    return count;
end

--- Returns contents of a map in a native Lua `table` class.
--- @return table returns
function Map:toTable()
    return self.__content;
end

function Map:getKeys()
    local result = {};

    for k, _ in pairs(self.__content) do
        table.insert(result);
    end

    return result;
end

function Map:getValues()
    local result = {};

    for _, v in pairs(self.__content) do
        table.insert(result);
    end

    return result;
end

-- Meta

function Map:__pairs()
    return next, self.__content, nil;
end

setmetatable(Map, {
    __index = Map;
    __pairs = Map.__pairs;
    __call = function(cls)
        return cls.new();
    end
})

return Map;
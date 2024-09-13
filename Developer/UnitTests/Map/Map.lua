local ContentProvider = System.getContentProvider();
local Map = ContentProvider.get("Utils.Map");

local tests = {};

function tests.clear()
    local map = Map();

    map:put("f", "value");
    map:clear();

    return map:isEmpty();
end

function tests.containsKey()
    local map = Map();

    map:put("key", "value");
    
    return map:containsKey("key");
end

function tests.containsValue()
    local map = Map();

    map:put("key", "value");
    
    return map:containsKey("key");
end

function tests.equals()
    local map1 = Map();
    local map2 = Map();

    map1:put("key", "value");
    map2:put("key", "value");

    return map1:equals(map2);
end

function tests.equals_false()
    local map1 = Map();
    local map2 = Map();

    map1:put("key", "value");
    map2:put("key", "other_value");

    return not map1:equals(map2);
end

function tests.forEach()
    local map = Map();
    local count = 0;
    
    map:put("key1", "value");
    map:put("key2", "value");
    map:put("key3", "value");
    map:put("key4", "value");

    map:forEach(function(key, value)
        if string.find(key, "key") then
            count = count + 1;
        end
    end);

    return count == map:size();
end

function tests.get()
    local map = Map();

    map:put("some_key", "some_value");
    
    return map:get("some_key") == "some_value";
end

function tests.isEmpty()
    local map = Map();

    return map:isEmpty();
end

function tests.putAll()
    local map1 = Map();
    local map2 = Map();

    map2:put("key1", "value");
    map2:put("key2", "value");

    map1:putAll(map2);

    return map1:containsKey("key1") and map1:size() == 2;
end

function tests.putIfAbsent()
    local map = Map();

    map:put("key1", "value");

    map:putIfAbsent("key1", "wrong_value");
    map:putIfAbsent("key2", "good_value");

    return map:get("key1") == "value" and map:get("key2") == "good_value";
end

function tests.remove()
    local map = Map();

    map:put("key", "value");
    assert(map:containsKey("key"), "Mapping was not put into Map!");
    map:remove("key", "value");

    return map:get("key") == nil;
end

function tests.replace()
    local map = Map();

    map:put("key", "value");
    assert(map:containsKey("key"), "Mapping was not put into Map!");
    map:replace("key", "new_value");
    map:replace("non_existant_key", "some_value");

    return map:get("key") == "new_value" and not map:containsKey("non_existant_key");
end

function tests.replaceAll()
    local map = Map();

    map:put("age1", 10);
    map:put("age2", 20);

    map:replaceAll(function(_, value) 
        return value * 2;
    end)

    return map:get("age1") == 20 and map:get("age2") == 40;
end

function tests.size()
    local map = Map();

    map:put("age1", 10);
    map:put("age2", 20);

    return map:size() == 2;
end

function tests.advancedGet()
    local map = Map();
    map:put("age1", 10);

    return map.age1 == 10;
end

function tests.advancedSet()
    local map = Map();
    map.age1 = 10;

    return map:get("age1") == 10;
end

function tests.iterator()
    local map = Map();
    local count = 0;

    map.key1 = "value1";
    map.key2 = "value2";
    map.key3 = "value3";
    map.key4 = "value4";

    for k, v in map do
        count = count + 1;
    end

    return count == 4;
end

return {
    tests = tests;
    titles = {
        clear = "clear() method;",
        containsKey = "containsKey() method;",
        containsValue = "containsValue() method;",
        equals = "equals() method;",
        equals_false = "equals() method (false positive);",
        forEach = "forEach() method;",
        get = "get() method;",
        isEmpty = "isEmpty() method;",
        putAll = "putAll() method;",
        putIfAbsent = "putIfAbsent() method;",
        remove = "remove() method;",
        replace = "replace() method;",
        replaceAll = "replaceAll() method;",
        size = "size() method;",
        advancedGet = "map.key GET interaction;",
        advancedSet = "map.key = value SET interaction;",
        iterator = "iteration without pairs",
    }
}
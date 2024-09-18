local function generateProxy(parent)
    local metatable = {
        __index = function(obj, key)
            if type(rawget(parent, key)) == "function" then
                return rawget(parent, key);
            elseif rawget(parent, key) == nil then
                return nil;
            else 
                local getter = "get" .. string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2, -1);
                if type(parent[getter]) == "function" then
                    return parent[getter](parent);
                else 
                    error("Attempt to access non-existent property or getter: " .. key)
                end
            end
        end,

        __newindex = function(obj, key, value) 
            local setter = "set" .. string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2, -1);
            if type(parent[setter]) == "function" then
                parent[setter](parent, value);
            else 
                error("Attempt to set non-existent property or setter: " .. key)
            end
        end,
    }

    return setmetatable({}, metatable);
end

return generateProxy;
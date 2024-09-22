local function serialize(value, visited, indent)
    local valueType = type(value)
    visited = visited or {}
    indent = indent or ""

    if valueType == "nil" then
        return "nil"
    elseif valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "function" then
        return '"function()"'
    elseif valueType == "table" then
        if visited[value] then
            return '"<loop>"'  -- Indicates a loop in the table
        end
        visited[value] = true

        local result = {}
        local nextIndent = indent .. "  "
        result[#result + 1] = "{\n"

        for k, v in pairs(value) do
            local serializedKey = serialize(k, visited, nextIndent)
            local serializedValue = serialize(v, visited, nextIndent)
            result[#result + 1] = nextIndent .. "[" .. serializedKey .. "] = " .. serializedValue .. ",\n"
        end

        result[#result + 1] = indent .. "}"
        return table.concat(result)
    else
        return '"<unsupported type>"'
    end
end

return serialize;
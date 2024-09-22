return function(arg)
    local args = {}
    local i = 1
    while i <= #arg do
        local current = arg[i]
        if string.sub(current, 1, 1) == "-" then
            local key = current
            local next_arg = arg[i + 1]
            if next_arg == nil or string.sub(next_arg, 1, 1) == "-" then
                -- Boolean flag (no value provided)
                args[key] = true
                i = i + 1
            else
                -- Collect all subsequent arguments that are not options
                local value_parts = {}
                local j = i + 1
                while j <= #arg and string.sub(arg[j], 1, 1) ~= "-" do
                    table.insert(value_parts, arg[j])
                    j = j + 1
                end
                local value = table.concat(value_parts, " ")

                -- Try to convert to number
                local num_value = tonumber(value)
                if num_value ~= nil then
                    args[key] = num_value
                else
                    args[key] = value
                end
                i = j
            end
        else
            -- Non-option argument (could store if needed)
            i = i + 1
        end
    end
    return args
end

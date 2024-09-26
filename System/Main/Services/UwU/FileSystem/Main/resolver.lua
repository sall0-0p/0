local resolver = {};
local root;

-- Yes, this was written by ChatGPT, I do not care. Not going to spend few hours writing this!
-- Function to split the path into elements, handling quoted parts with spaces
local function split_path(path)
    local elements = {};  -- Table to store the path elements
    local index = 1;      -- Current position in the path string
    local length = #path; -- Total length of the path string

    while index <= length do
        -- Skip any leading '/'
        while index <= length and path:sub(index, index) == '/' do
            index = index + 1;
        end

        if index > length then break end

        local character = path:sub(index, index);

        if character == '"' then
            -- Quoted element (handles names with spaces)
            index = index + 1;          -- Move past the opening quote
            local start_index = index;  -- Start position of the element

            -- Find the closing quote
            while index <= length and path:sub(index, index) ~= '"' do
                index = index + 1;
            end

            if index > length then
                error('Unclosed quote in path');
            end

            local element = path:sub(start_index, index - 1);
            table.insert(elements, element);
            index = index + 1;  -- Skip the closing quote
        else
            -- Unquoted element
            local start_index = index;  -- Start position of the element

            -- Read until the next '/' or end of the string
            while index <= length and path:sub(index, index) ~= '/' do
                index = index + 1;
            end

            local element = path:sub(start_index, index - 1);
            table.insert(elements, element);
        end
    end

    return elements;
end

-- Function to resolve an absolute path starting from root
function resolver.resolvePath(path)
    local elements = split_path(path);  -- Split the path into elements
    local current_object = root;        -- Start from the root directory

    for _, element in ipairs(elements) do
        if element == '..' then
            -- Move up to the parent directory
            if not current_object.parent then
                error('Invalid path: reached root directory');
            end
            current_object = current_object.parent;
        elseif element ~= '.' then
            -- Move to the child directory or file
            current_object = current_object[element];
            if not current_object then
                error('Invalid path: "' .. element .. '" not found');
            end
        end
        -- Ignore '.' as it refers to the current directory
    end

    return current_object;
end

-- Function to resolve a relative path starting from a given object
function resolver.resolveLocalPath(object, path)
    local elements = split_path(path);  -- Split the path into elements
    local current_object = object;      -- Start from the given object

    for _, element in ipairs(elements) do
        if element == '..' then
            -- Move up to the parent directory
            if not current_object.parent then
                error('Invalid path: reached root directory');
            end
            current_object = current_object.parent;
        elseif element ~= '.' then
            -- Move to the child directory or file
            current_object = current_object[element];
            if not current_object then
                error('Invalid path: "' .. element .. '" not found');
            end
        end
        -- Ignore '.' as it refers to the current directory
    end

    return current_object;
end

function resolver.init(dir)
    root = dir;
end

return resolver;
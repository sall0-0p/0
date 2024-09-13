local ENUM_FOLDER = "/System/Main/Globals/Enums"

local function registerEnums(path)
    local Enums = {};
    for _, item in pairs(fs.list(path)) do
        local contents = require(string.gsub(path, "/", ".") .. "." .. string.gsub(item, ".lua", ""));
        Enums[string.gsub(item, ".lua", "")] = contents;
    end

    return Enums;
end

return registerEnums(ENUM_FOLDER);
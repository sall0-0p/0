SYSTEM_BOOT_FOLDER = "/System/Boot";

if fs.exists(SYSTEM_BOOT_FOLDER) then
    local items = fs.list(SYSTEM_BOOT_FOLDER);

    for _, item in pairs(items) do
        if not fs.isDir(fs.combine(SYSTEM_BOOT_FOLDER, item)) then
            require(string.gsub(SYSTEM_BOOT_FOLDER .. "/" .. item:gsub(".lua", ""), "/", "."));
        end
    end
end


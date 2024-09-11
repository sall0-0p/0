local DEFAULT_LOGS_LOCATION = "/.var/logs";
local MESSAGE_INDENT = 55;
local MAX_LOGS = 5;

--- Static instance of logger
local Logger = {};
local latestPath = fs.combine(DEFAULT_LOGS_LOCATION, "latest.log");

function Logger.__init()
    local oldLatestLog = fs.open(latestPath, "r");
    local timestamp = oldLatestLog.readLine(1);

    oldLatestLog.close();
    fs.move(latestPath, fs.combine(fs.getDir(latestPath), string.format("log-%s.log", timestamp)));

    local newLatestLog = fs.open(latestPath, "w");
    ---@diagnostic disable-next-line: param-type-mismatch
    newLatestLog.writeLine(os.time(os.date("!*t")));
    newLatestLog.close();
end

-- No semicolons cuz its shitty chatGPT utility function.rr
local function clearLogs(logFolder)
    local logs = {}

    for _, file in ipairs(fs.list(logFolder)) do
        local filePath = fs.combine(logFolder, file)

        if not fs.isDir(filePath) and file ~= "latest.log" then
            local attr = fs.attributes(filePath)
            table.insert(logs, { path = filePath, modified = attr.modified })
        end
    end

    table.sort(logs, function(a, b) return a.modified < b.modified end)

    while #logs > MAX_LOGS - 1 do
        local oldest = table.remove(logs, 1)
        fs.delete(oldest.path)
        print("Deleted old log:", oldest.path)
    end
end

local function log(type, message, ...)
    local logFile = fs.open(latestPath, "a");
    local timestamp = os.date("%T");
    local debugInfo = debug.getinfo(3);
    ---@diagnostic disable-next-line: undefined-field
    local prefix = string.format("[%s] %s ", timestamp, string.format("%s:%d", debugInfo.short_src, debugInfo.currentline));
    local content = string.format("[%s] " .. message, type,  ...);

    for i = #prefix, MESSAGE_INDENT do
        prefix = prefix .. " ";
    end

    logFile.writeLine(prefix .. "| " .. content);
    logFile.close();
end

function Logger.fatal(message, ...)
    log("FATAL", message, ...);
end

function Logger.error(message, ...)
    log("ERROR", message, ...);
end

function Logger.warn(message, ...)
    log("WARN", message, ...);
end

function Logger.trace(message, ...)
    log("TRACE", message, ...);
end

function Logger.debug(message, ...)
    log("DEBUG", message, ...);
end

function Logger.info(message, ...)
    log("INFO", message, ...);
end

clearLogs(DEFAULT_LOGS_LOCATION);
Logger.__init();
return Logger;
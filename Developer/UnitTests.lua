local argparser = require(".System.Main.Packages.UwU.Utils.Modules.argparser");

local successCount = 0;
local totalCount = 0;
local args = argparser(arg);
local hideSuccess = args["-s"] or false;
local showStackTrace = args["-t"] or false;

local testsFolder = args["-d"] or "/Developer/Tests";

local function turnPathIntoRequire(path)
    local result = string.gsub(path, "%.[a-zA-Z]+$", "");
    result = string.gsub(result, "/", ".");

    return result;
end

local function runTestsInFolder(path)
    local contents = fs.list(path)
    for _, v in pairs(contents) do
        if fs.isDir(fs.combine(testsFolder, v)) then
            runTestsInFolder(fs.combine(path, v))
        else
            local testingData = require("." .. turnPathIntoRequire(fs.combine(path, v)))

            for title, test in pairs(testingData.tests) do
                local result, errorTbl = xpcall(test, function(err)
                    -- Capture the error and traceback from the test itself
                    if showStackTrace then
                        return {err, debug.traceback("", 2)}
                    else 
                        return {err}
                    end
                    
                end)

                if result and errorTbl == true then
                    if not hideSuccess then
                        term.setTextColor(colors.green);
                        print(string.format("| Success | %s: %s", v, (testingData.titles[title] or title)))
                    end

                    successCount = successCount + 1
                    totalCount = totalCount + 1
                else
                    term.setTextColor(colors.red)
                    print(string.format("| Failure | %s: %s", v, (testingData.titles[title] or title)))

                    totalCount = totalCount + 1

                    -- Print error message with captured traceback
                    if errorTbl then
                        term.setTextColor(colors.lightGray);
                        print("|  Note   | " .. errorTbl[1])
                        
                        if errorTbl[2] and showStackTrace then
                            term.setTextColor(colors.gray);
                            print(errorTbl[2])
                        end
                    end
                end

                term.setTextColor(colors.white);
            end
        end
    end
end

-- actual code

print("Running tests...");
print();

runTestsInFolder(testsFolder);

print()
print(string.format("[%d/%d]", successCount, totalCount));
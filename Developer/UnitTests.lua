local TESTS_FOLDER = "/Developer/UnitTests";
local successCount = 0;
local totalCount = 0;
local hideSuccess = arg[1] == "-s"

local function turnPathIntoRequire(path)
    local result = string.gsub(path, "%.[a-zA-Z]+$", "");
    result = string.gsub(result, "/", ".");

    return result;
end

local function runTestsInFolder(path)
    local contents = fs.list(path);
    for _, v in pairs(contents) do
        if fs.isDir(fs.combine(TESTS_FOLDER, v)) then
            runTestsInFolder(fs.combine(path, v));
        else
            local testingData = require("." .. turnPathIntoRequire(fs.combine(path, v)));

            for title, test in pairs(testingData.tests) do
                local result, errorMsg = pcall(test);
                if result and errorMsg == true then
                    if not hideSuccess then
                        print(string.format("| Success | %s: %s", v, (testingData.titles[title] or title)));
                    end

                    successCount = successCount + 1;
                    totalCount = totalCount + 1;
                else
                    print(string.format("| Failure | %s: %s", v, (testingData.titles[title] or title)));

                    totalCount = totalCount + 1;
                end

                if result == false and errorMsg then
                    print(errorMsg);
                end
            end
        end
    end
end

-- actual code

print("Running tests...");
print();

runTestsInFolder(TESTS_FOLDER);

print()
print(string.format("[%d/%d]", successCount, totalCount));
local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

-- Test Suite for FileSystem Package (File and Directory)

local ContentProvider = System:getContentProvider();
local FileSystem = ContentProvider.get("UwU.FileSystem.Main");
local Directory = ContentProvider.get("UwU.FileSystem.Directory");
local File = ContentProvider.get("UwU.FileSystem.File");

FileSystem();

local root = FileSystem.getRoot();
local testingDirectory = Directory("Testing", root);

local tempDirCounter = 0

local function getUniqueTempDirName()
    tempDirCounter = tempDirCounter + 1
    return "TempDir_" .. tempDirCounter
end

local function cleanupDirectory(dir)
    dir:delete();
end

local tests = {};

-- Test creating a new file inside a directory
local testFileCreation = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    if tempDir:getChildCount() ~= 1 then
        error("Child count is incorrect: expected 1, got " .. tempDir:getChildCount())
    end
    if file:getPath() ~= tempDir:getPath() .. "/MyFile.txt" then
        error("File path is incorrect: expected '" .. tempDir:getPath() .. "/MyFile.txt', got '" .. file:getPath() .. "'")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test creating a new directory inside another directory
local testDirectoryCreation = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local subDir = Directory.new("SubDir", tempDir)

    if tempDir:getChildCount() ~= 1 then
        error("Child count is incorrect: expected 1, got " .. tempDir:getChildCount())
    end
    if subDir:getPath() ~= tempDir:getPath() .. "/SubDir" then
        error("Sub-directory path is incorrect: expected '" .. tempDir:getPath() .. "/SubDir', got '" .. subDir:getPath() .. "'")
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(subDir:getPath()) then
        error("Directory does not exist in the CraftOS file system at path: " .. subDir:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test moving a file to another directory
local testFileMove = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory(tempDirName, testingDirectory)
    local subDir = Directory("SubDir", tempDir)
    local file = File("MyFile.txt", tempDir)

    print(serializer(file));
    print(serializer(subDir));

    file:move(subDir)

    if subDir:getChildCount() ~= 1 then
        error("Child count in SubDir is incorrect: expected 1, got " .. subDir:getChildCount())
    end
    if file:getPath() ~= subDir:getPath() .. "/MyFile.txt" then
        error("File path after move is incorrect: expected '" .. subDir:getPath() .. "/MyFile.txt', got '" .. file:getPath() .. "'")
    end

    -- Check if the file was correctly moved in the CraftOS file system
    if not fs.exists(file:getPath()) then
        error("Moved file does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test copying a file to another directory
local testFileCopy = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local subDir = Directory.new("SubDir", tempDir)
    local file = File.new("MyFile.txt", tempDir)

    local copyFile = file:copy(subDir)

    if subDir:getChildCount() ~= 1 then
        error("Child count in SubDir is incorrect: expected 1, got " .. subDir:getChildCount())
    end
    if copyFile:getPath() ~= subDir:getPath() .. "/MyFile.txt" then
        error("Copy file path is incorrect: expected '" .. subDir:getPath() .. "/MyFile.txt', got '" .. copyFile:getPath() .. "'")
    end

    -- Check if the file was correctly copied in the CraftOS file system
    if not fs.exists(copyFile:getPath()) then
        error("Copied file does not exist in the CraftOS file system at path: " .. copyFile:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test deleting a file from a directory
local testFileDelete = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    file:delete()

    if tempDir:getChildCount() ~= 0 then
        error("Child count after deletion is incorrect: expected 0, got " .. tempDir:getChildCount())
    end

    -- Check if the file was deleted in the CraftOS file system
    if fs.exists(file:getPath()) then
        error("File was not deleted from the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test renaming a file
local testFileRename = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    file:rename("NewFile.txt")

    if file:getPath() ~= tempDir:getPath() .. "/NewFile.txt" then
        error("File path after rename is incorrect: expected '" .. tempDir:getPath() .. "/NewFile.txt', got '" .. file:getPath() .. "'")
    end
    if tempDir:findChildByName("NewFile.txt") ~= file then
        error("File rename not reflected in parent's children.")
    end

    -- Check if the renamed file exists in the CraftOS file system
    if not fs.exists(file:getPath()) then
        error("Renamed file does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test FsNode: isDirectory for File and Directory
local testIsDirectory = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    if tempDir:isDirectory() ~= true then
        error("Directory isDirectory check failed: expected true, got false")
    end
    if file:isDirectory() ~= false then
        error("File isDirectory check failed: expected false, got true")
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(tempDir:getPath()) then
        error("Directory does not exist in the CraftOS file system at path: " .. tempDir:getPath())
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test FsNode: getPath method
local testGetPath = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    if file:getPath() ~= tempDir:getPath() .. "/MyFile.txt" then
        error("File getPath returned wrong path: expected '" .. tempDir:getPath() .. "/MyFile.txt', got '" .. file:getPath() .. "'")
    end
    if tempDir:getPath() ~= testingDirectory:getPath() .. "/" .. tempDirName then
        error("Directory getPath returned wrong path: expected '" .. testingDirectory:getPath() .. "/" .. tempDirName .. "', got '" .. tempDir:getPath() .. "'")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(tempDir:getPath()) then
        error("Directory does not exist in the CraftOS file system at path: " .. tempDir:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test FsNode: isReadOnly method
local testIsReadOnly = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local file = File.new("MyFile.txt", tempDir)

    if file.isReadOnly ~= false then
        error("File isReadOnly check failed: expected false, got true")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test renaming a directory
local testDirectoryRename = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local subDir = Directory.new("SubDir", tempDir)

    subDir:rename("RenamedDir")

    if subDir:getPath() ~= tempDir:getPath() .. "/RenamedDir" then
        error("Directory rename failed: expected '" .. tempDir:getPath() .. "/RenamedDir', got '" .. subDir:getPath() .. "'")
    end
    if tempDir:findChildByName("RenamedDir") ~= subDir then
        error("Directory rename not reflected in parent's children.")
    end

    -- Check if the renamed directory exists in the CraftOS file system
    if not fs.exists(subDir:getPath()) then
        error("Renamed directory does not exist in the CraftOS file system at path: " .. subDir:getPath())
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Test clearing a directory
local testDirectoryClear = function()
    local tempDirName = getUniqueTempDirName()
    local tempDir = Directory.new(tempDirName, testingDirectory)
    local subDir = Directory.new("SubDir", tempDir)
    local file1 = File.new("File1.txt", subDir)
    local file2 = File.new("File2.txt", subDir)

    subDir:clear()

    if subDir:getChildCount() ~= 0 then
        error("Directory clear failed: expected 0 children, got " .. subDir:getChildCount())
    end

    -- Check if files were deleted in the CraftOS file system
    if fs.exists(file1:getPath()) or fs.exists(file2:getPath()) then
        error("Files were not deleted from the CraftOS file system after clearing the directory")
    end

    -- Cleanup
    cleanupDirectory(tempDir)
    return true;
end

-- Insert the test functions into the `tests` table
tests.testFileCreation = testFileCreation
tests.testDirectoryCreation = testDirectoryCreation
tests.testFileMove = testFileMove
tests.testFileCopy = testFileCopy
tests.testFileDelete = testFileDelete
tests.testFileRename = testFileRename
tests.testIsDirectory = testIsDirectory
tests.testGetPath = testGetPath
tests.testIsReadOnly = testIsReadOnly
tests.testDirectoryRename = testDirectoryRename
tests.testDirectoryClear = testDirectoryClear

return {
    tests = tests,
    titles = {
        testFileCreation = "Test file creation inside a directory",
        testDirectoryCreation = "Test directory creation inside another directory",
        testFileMove = "Test moving a file to another directory",
        testFileCopy = "Test copying a file to another directory",
        testFileDelete = "Test deleting a file from a directory",
        testFileRename = "Test renaming a file",
        testIsDirectory = "Test isDirectory for File and Directory",
        testGetPath = "Test getPath method for File and Directory",
        testIsReadOnly = "Test isReadOnly method for File and Directory",
        testDirectoryRename = "Test renaming a directory",
        testDirectoryClear = "Test clearing all children from a directory"
    },
    cleanup = function() 
        testingDirectory:delete();
    end
}

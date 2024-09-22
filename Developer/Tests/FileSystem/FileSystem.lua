local serializer = require(".System.Main.Packages.UwU.Utils.Modules.serializer");

-- Test Suite for FileSystem Package (File and Directory)

local ContentProvider = System:getContentProvider();

local File = ContentProvider.get("UwU.FileSystem.File");
local Directory = ContentProvider.get("UwU.FileSystem.Directory");

local tests = {};

-- Helper function to clean up the root directory
local function cleanupDirectory(rootDir)
    fs.delete("/Root");
end

-- Test creating a new file inside a directory
local testFileCreation = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    if rootDir:getChildCount() ~= 1 then
        error("Child count is incorrect: expected 1, got " .. rootDir:getChildCount())
    end
    if file:getPath() ~= "/Root/MyFile.txt" then
        error("File path is incorrect: expected '/Root/MyFile.txt', got '" .. file:getPath() .. "'")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test creating a new directory inside another directory
local testDirectoryCreation = function()
    local rootDir = Directory.new("Root", nil)
    local subDir = Directory.new("SubDir", rootDir)

    if rootDir:getChildCount() ~= 1 then
        error("Child count is incorrect: expected 1, got " .. rootDir:getChildCount())
    end
    if subDir:getPath() ~= "/Root/SubDir" then
        error("Sub-directory path is incorrect: expected '/Root/SubDir', got '" .. subDir:getPath() .. "'")
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(subDir:getPath()) then
        error("Directory does not exist in the CraftOS file system at path: " .. subDir:getPath())
    end

    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test moving a file to another directory
local testFileMove = function()
    local rootDir = Directory.new("Root", nil)
    local subDir = Directory.new("SubDir", rootDir)
    local file = File.new("MyFile.txt", rootDir)

    file:move(subDir)

    if subDir:getChildCount() ~= 1 then
        error("Child count in SubDir is incorrect: expected 1, got " .. subDir:getChildCount())
    end
    if file:getPath() ~= "/Root/SubDir/MyFile.txt" then
        error("File path after move is incorrect: expected '/Root/SubDir/MyFile.txt', got '" .. file:getPath() .. "'")
    end

    -- Check if the file was correctly moved in the CraftOS file system
    if not fs.exists(file:getPath()) then
        error("Moved file does not exist in the CraftOS file system at path: " .. file:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test copying a file to another directory
local testFileCopy = function()
    local rootDir = Directory.new("Root", nil)
    local subDir = Directory.new("SubDir", rootDir)
    local file = File.new("MyFile.txt", rootDir)

    local copyFile = file:copy(subDir)

    if subDir:getChildCount() ~= 1 then
        error("Child count in SubDir is incorrect: expected 1, got " .. subDir:getChildCount())
    end
    if copyFile:getPath() ~= "/Root/SubDir/MyFile.txt" then
        error("Copy file path is incorrect: expected '/Root/SubDir/MyFile.txt', got '" .. copyFile:getPath() .. "'")
    end

    -- Check if the file was correctly copied in the CraftOS file system
    if not fs.exists(copyFile:getPath()) then
        error("Copied file does not exist in the CraftOS file system at path: " .. copyFile:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test deleting a file from a directory
local testFileDelete = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    file:delete()

    if rootDir:getChildCount() ~= 0 then
        error("Child count after deletion is incorrect: expected 0, got " .. rootDir:getChildCount())
    end

    -- Check if the file was deleted in the CraftOS file system
    if fs.exists(file:getPath()) then
        error("File was not deleted from the CraftOS file system at path: " .. file:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test renaming a file
local testFileRename = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    file:rename("NewFile.txt")

    if file:getPath() ~= "/Root/NewFile.txt" then
        error("File path after rename is incorrect: expected '/Root/NewFile.txt', got '" .. file:getPath() .. "'")
    end
    if rootDir:findChildByName("NewFile.txt") ~= file then
        error("File rename not reflected in parent's children.")
    end

    -- Check if the renamed file exists in the CraftOS file system
    if not fs.exists(file:getPath()) then
        error("Renamed file does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test FsNode: isDirectory for File and Directory
local testIsDirectory = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    if rootDir:isDirectory() ~= true then
        error("Root directory isDirectory check failed: expected true, got false")
    end
    if file:isDirectory() ~= false then
        error("File isDirectory check failed: expected false, got true")
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(rootDir:getPath()) then
        error("Root directory does not exist in the CraftOS file system at path: " .. rootDir:getPath())
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test FsNode: getPath method
local testGetPath = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    if file:getPath() ~= "/Root/MyFile.txt" then
        error("File getPath returned wrong path: expected '/Root/MyFile.txt', got '" .. file:getPath() .. "'")
    end
    if rootDir:getPath() ~= "/Root" then
        error("Root directory getPath returned wrong path: expected '/Root', got '" .. rootDir:getPath() .. "'")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end

    -- Check directory existence in CraftOS file system
    if not fs.exists(rootDir:getPath()) then
        error("Root directory does not exist in the CraftOS file system at path: " .. rootDir:getPath())
    end

    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test FsNode: isReadOnly method
local testIsReadOnly = function()
    local rootDir = Directory.new("Root", nil)
    local file = File.new("MyFile.txt", rootDir)

    if file.isReadOnly ~= false then
        error("File isReadOnly check failed: expected false, got true")
    end

    -- Check file existence in CraftOS file system
    if not fs.exists(file:getPath()) then
        error("File does not exist in the CraftOS file system at path: " .. file:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test FsNode: rename a directory
local testDirectoryRename = function()
    local rootDir = Directory.new("Root", nil)
    local subDir = Directory.new("SubDir", rootDir)

    subDir:rename("RenamedDir")

    if subDir:getPath() ~= "/Root/RenamedDir" then
        error("Directory rename failed: expected '/Root/RenamedDir', got '" .. subDir:getPath() .. "'")
    end
    if rootDir:findChildByName("RenamedDir") ~= subDir then
        error("Directory rename not reflected in parent's children.")
    end

    -- Check if the renamed directory exists in the CraftOS file system
    if not fs.exists(subDir:getPath()) then
        error("Renamed directory does not exist in the CraftOS file system at path: " .. subDir:getPath())
    end
    
    -- Cleanup
    cleanupDirectory(rootDir)
    return true;
end

-- Test clearing a directory
local testDirectoryClear = function()
    local rootDir = Directory.new("Root", nil)
    local subDir = Directory.new("SubDir", rootDir)
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
    cleanupDirectory(rootDir)
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
    }
}

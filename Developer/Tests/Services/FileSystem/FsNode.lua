local ContentProvider = System.getContentProvider()
local FsNode = ContentProvider.get("FileSystem.FsNode");

-- Test file for FsNode

local tests = {}

-- Test for __simplifyName
function tests.testSimplifyName()
    local node = FsNode.new("Test Node Name", nil, false)
    return node.simplifiedName == "Test_Node_Name"
end

-- Test for simplified name with special characters
function tests.testSimplifyNameSpecialCharacters()
    local node = FsNode.new("Invalid@Name!", nil, false)
    return node.simplifiedName == "InvalidName"
end

-- Test for path generation with no parent (root node)
function tests.testPathGenerationNoParent()
    local node = FsNode.new("Root", nil, false)
    return node.path == "/Root"
end

-- Test for path generation with a parent node
function tests.testPathGenerationWithParent()
    local parentNode = FsNode.new("Parent", nil, false)
    local childNode = FsNode.new("Child", parentNode, false)
    return childNode.path == "/Parent/Child"
end

-- Test for path generation with multiple parents (nested nodes)
function tests.testPathGenerationMultipleParents()
    local grandParentNode = FsNode.new("GrandParent", nil, false)
    local parentNode = FsNode.new("Parent", grandParentNode, false)
    local childNode = FsNode.new("Child", parentNode, false)
    return childNode.path == "/GrandParent/Parent/Child"
end

return {
    tests = tests,
    titles = {
        testSimplifyName = "Simplify name replaces spaces and removes special characters",
        testSimplifyNameSpecialCharacters = "Simplify name handles special characters correctly",
        testPathGenerationNoParent = "Path generation works for node with no parent",
        testPathGenerationWithParent = "Path generation works for node with a parent",
        testPathGenerationMultipleParents = "Path generation works for node with multiple parent ancestors"
    }
}

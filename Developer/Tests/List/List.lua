local ContentProvider = System.getContentProvider();
local List = ContentProvider.get("UwU.Utils.List");

local tests = {}

-- Test creating a new list
function tests.createList()
    local list = List()
    return list:isEmpty()
end

-- Test adding elements to the list
function tests.add()
    local list = List()
    list:add("element1")
    return list:get(1) == "element1" and list:size() == 1
end

-- Test adding elements at a specific index
function tests.addAt()
    local list = List()
    list:add("element1")
    list:addAt(1, "element0")
    return list:get(1) == "element0" and list:get(2) == "element1"
end

-- Test removing an element by index
function tests.removeAt()
    local list = List()
    list:add("element1")
    list:add("element2")
    local removedElement = list:removeAt(1)
    return removedElement == "element1" and list:get(1) == "element2"
end

-- Test removing an element by value
function tests.remove()
    local list = List()
    list:add("element1")
    list:add("element2")
    local result = list:remove("element1")
    return result == true and list:get(1) == "element2"
end

-- Test getting an element
function tests.get()
    local list = List()
    list:add("element1")
    return list:get(1) == "element1"
end

-- Test setting an element
function tests.set()
    local list = List()
    list:add("element1")
    local oldElement = list:set(1, "element2")
    return oldElement == "element1" and list:get(1) == "element2"
end

-- Test the size of the list
function tests.size()
    local list = List()
    list:add("element1")
    list:add("element2")
    return list:size() == 2
end

-- Test if the list is empty
function tests.isEmpty()
    local list = List()
    return list:isEmpty()
end

-- Test if the list contains an element
function tests.contains()
    local list = List()
    list:add("element1")
    return list:contains("element1") == true and list:contains("element2") == false
end

-- Test finding the index of an element
function tests.indexOf()
    local list = List()
    list:add("element1")
    list:add("element2")
    list:add("element1")
    return list:indexOf("element1") == 1
end

-- Test finding the last index of an element
function tests.lastIndexOf()
    local list = List()
    list:add("element1")
    list:add("element2")
    list:add("element1")
    return list:lastIndexOf("element1") == 3
end

-- Test clearing the list
function tests.clear()
    local list = List()
    list:add("element1")
    list:clear()
    return list:isEmpty()
end

-- Test creating a sublist
function tests.subList()
    local list = List()
    list:add("element1")
    list:add("element2")
    list:add("element3")
    local sublist = list:subList(2, 3)
    return sublist:size() == 1 and sublist:get(1) == "element2"
end

-- Test converting the list to a table
function tests.toTable()
    local list = List()
    list:add("element1")
    list:add("element2")
    local tableRepresentation = list:toTable()
    return tableRepresentation[1] == "element1" and tableRepresentation[2] == "element2"
end

-- Test iteration over the list using __pairs
function tests.iteration()
    local list = List()
    list:add("element1")
    list:add("element2")
    local elements = {}
    for key, value in list do
        table.insert(elements, value)
    end
    return elements[1] == "element1" and elements[2] == "element2"
end

-- Test reading items like list[1]
function tests.readIndex()
    local list = List()
    list:add("element1")
    return list[1] == "element1"
end

-- Test writing items like list[1] = "new value"
function tests.writeIndex()
    local list = List()
    list:add("element1")
    list[1] = "new value"
    return list:get(1) == "new value"
end

-- Test creating a new list using List()
function tests.createListAlternate()
    local list = List()
    return list:isEmpty()
end

return {
    tests = tests;
    titles = {
        createList = "Test creating a new list;",
        add = "Test adding elements to the list;",
        addAt = "Test adding elements at a specific index;",
        removeAt = "Test removing an element by index;",
        remove = "Test removing an element by value;",
        get = "Test getting an element;",
        set = "Test setting an element;",
        size = "Test the size of the list;",
        isEmpty = "Test if the list is empty;",
        contains = "Test if the list contains an element;",
        indexOf = "Test finding the index of an element;",
        lastIndexOf = "Test finding the last index of an element;",
        clear = "Test clearing the list;",
        subList = "Test creating a sublist;",
        toTable = "Test converting the list to a table;",
        iteration = "Test iteration over the list using __pairs;",
        readIndex = "Test reading items like list[1];",
        writeIndex = "Test writing items like list[1] = 'value';",
        createListAlternate = "Test creating a new list using List();",
    }
}

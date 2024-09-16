--[[
List class implementation in Lua for ComputerCraft.
This class emulates Java's List interface.
]]
--- @class List;
local List = {}
List.__index = List

-- Constructor
function List.new()
    local list = { __content = {} }
    setmetatable(list, List)

    local proxy = setmetatable({}, {
        __index = function (_, key)
            if rawget(list, key) then
                return rawget(list, key);
            elseif rawget(List, key) then
                return rawget(List, key)
            else
                return rawget(rawget(list, "__content"), key);
            end
        end,

        __newindex = function (obj, key, value)
            if type(key) ~= "number" then
                error("Key has to be a number!");
            end

            if rawget(list, key) then
                rawset(list, key, value)
            else 
                rawset(rawget(list, "__content"), key, value)
            end
        end,

        __call = function(_, _, key) 
            return next(list.__content, key);
        end
    })

    return proxy
end

--[[
Adds an element to the end of the list.
@param element The element to add.
]]
function List:add(element)
    table.insert(self.__content, element)
end

--[[
Inserts an element at the specified index.
@param index The index at which to insert.
@param element The element to insert.
]]
function List:addAt(index, element)
    table.insert(self.__content, index, element)
end

--[[
Removes the element at the specified index.
@param index The index of the element to remove.
@return The removed element.
]]
function List:removeAt(index)
    local removedElement = table.remove(self.__content, index)
    return removedElement
end

--[[
Removes the first occurrence of the specified element.
@param element The element to remove.
@return true if the element was found and removed, false otherwise.
]]
function List:remove(element)
    for index, value in ipairs(self.__content) do
        if value == element then
            table.remove(self.__content, index)
            return true
        end
    end
    return false
end

--[[
Returns the element at the specified index.
@param index The index of the element to return.
@return The element at the specified index.
]]
function List:get(index)
    return self.__content[index]
end

--[[
Replaces the element at the specified index with the specified element.
@param index The index of the element to replace.
@param element The element to be stored.
@return The element previously at the specified position.
]]
function List:set(index, element)
    local oldElement = self.__content[index]
    self.__content[index] = element
    return oldElement
end

--[[
Returns the number of elements in the list.
@return The number of elements.
]]
function List:size()
    return #self.__content
end

--[[
Returns true if the list contains no elements.
@return true if the list is empty, false otherwise.
]]
function List:isEmpty()
    return #self.__content == 0
end

--[[
Returns true if the list contains the specified element.
@param element The element to check for.
@return true if the list contains the element, false otherwise.
]]
function List:contains(element)
    for _, value in ipairs(self.__content) do
        if value == element then
            return true
        end
    end
    return false
end

--[[
Returns the index of the first occurrence of the specified element.
@param element The element to search for.
@return The index of the element or nil if not found.
]]
function List:indexOf(element)
    for index, value in ipairs(self.__content) do
        if value == element then
            return index
        end
    end
    return nil
end

--[[
Returns the index of the last occurrence of the specified element.
@param element The element to search for.
@return The index of the element or nil if not found.
]]
function List:lastIndexOf(element)
    for index = #self.__content, 1, -1 do
        if self.__content[index] == element then
            return index
        end
    end
    return nil
end

--[[
Removes all elements from the list.
]]
function List:clear()
    for key in pairs(self.__content) do
        self.__content[key] = nil
    end
end

--[[
Returns a new list that is a sublist of this list.
@param fromIndex The start index (inclusive).
@param toIndex The end index (exclusive).
@return A new List containing the specified range.
]]
function List:subList(fromIndex, toIndex)
    local sublist = List:new()
    for index = fromIndex, toIndex - 1 do
        sublist:add(self.__content[index])
    end
    return sublist
end

--[[
Returns a table containing all elements in the list.
@return A table containing all elements.
]]
function List:toTable()
    local tableRepresentation = {}
    for index, value in ipairs(self.__content) do
        tableRepresentation[index] = value
    end
    return tableRepresentation
end

--[[
Overrides the __pairs metamethod to allow iteration over the list.
]]
function List:__pairs()
    return next, self.__content, nil;
end

-- Set the __pairs metamethod
setmetatable(List, {
    __index = List;
    __pairs = List.__pairs;
    __call = function (cls, ...)
        return cls.new(...);
    end
})

return List

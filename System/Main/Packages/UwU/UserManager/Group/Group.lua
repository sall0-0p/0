--- @class Group
--- @field id number
--- @field groupName string
--- @field members table
local Group = {}
Group.__index = Group;

-- Constructor
function Group.new(id, groupName)
    local group = setmetatable({}, Group);
    group.id = id;
    group.groupName = groupName;
    group.members = {};  -- List of user IDs
    return group;
end

-- Load from data
function Group.fromData(data)
    local group = setmetatable({}, Group);
    group.id = data.id;
    group.groupName = data.groupName;
    group.members = data.members or {};
    return group;
end

-- Convert to table
function Group:toTable()
    return {
        id = self.id;
        groupName = self.groupName;
        members = self.members;
    }
end

-- Add user to group
function Group:addUser(userId)
    if not self.members[userId] then
        self.members[userId] = true;
    end
end

-- Remove user from group
function Group:removeUser(userId)
    self.members[userId] = nil;
end

-- Check if user is a member
function Group:isMember(userId)
    return self.members[userId] ~= nil;
end

setmetatable(Group, {
    __index = Group;
    __call = function(cls, ...)
        return cls.new(...)
    end
});

return Group;

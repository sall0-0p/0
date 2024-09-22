local hasher = require(".System.Main.Packages.Utils.Modules.sha256");

--- @class User
--- @field id number
--- @field username string
--- @field salt string
--- @field hashedPassword string
local User = {}
User.__index = User;

-- Utilities

function User.new(id, username, password)
    local user = setmetatable({}, User);
    
    user.id = id;
    user.username = username;
    user.salt = hasher.generate_salt(16);
    user.hashedPassword = hasher.generate_hash(user.salt .. password);

    return user;
end

function User.fromData(data);
    local user = setmetatable({}, User);

    user.id = data.id;
    user.username = data.username;
    user.salt = data.salt;
    user.hashedPassword = data.hashedPassword;

    return user;
end

function User:toTable()
    return {
        id = self.id;
        username = self.username;
        salt = self.salt;
        hashedPassword = self.hashedPassword;
    }
end

function User:validatePassword(attemptedPassword)
    local attemptedHash = hasher.generate_hash(self.salt .. attemptedPassword);

    return attemptedHash == self.hashedPassword;
end

function User:changePassword(newPassword)
    self.hashedPassword = hasher.generate_hash(self.salt .. newPassword);
end

setmetatable(User, {
    __index = User;
    __call = function(cls, ...)
        return cls.new(...)
    end
});

return User;
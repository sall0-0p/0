local ContentProvider = System.getContentProvider();

local proxygen = require(".System.Main.Packages.Utils.Modules.proxygen");

local Thread = {};
Thread.__index = Thread;

function Thread.new(process, func)
    local thread = setmetatable({}, Thread);

    thread.parent = process;
    thread.coroutine = coroutine.create(func);
    thread.timer = 0;
    thread.filter = nil;

    --FIXME: Replace with full proxy with full set of getters and setters.
    return thread; -- proxygen(thread);
end

function Thread:sleep(time)
    self.timer = os.startTimer(time);
end

-- getters

setmetatable(Thread, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

return Thread;

callback = require("callback")

local moduleTable = {}

local __events = {}
local __event = {
    id = nil, -- event id
    name = nil, -- event name
    channel = nil, -- channel this event would occur with
    callback = nil, -- callback 
    params = nil, -- callback params
    
    copy = function(self)
        return new(self.name, self.channel, self.callback, unpack(self.params))
    end,
    
    call = function(self, ...)
        if self.callback ~= nil and self.callback.name ~= nil then
            if #({...}) > 0 then
                return self.callback:call(self.id, ...)
            else
                return self.callback:call(self.id, self.params)
            end
        end
        return nil
    end,
    
    queue = function(self, ...)
        print("    queue "..self.id)
        if #({...}) > 0 then
            return os.queueEvent(self.name, self.id, self.channel, nil, ...)
        else
            return os.queueEvent(self.name, self.id, self.channel, nil, unpack(self.params))
        end
    end,
    
    setChannel = function(self, echannel)
        if type(echannel) == "number" then
            self.channel = echannel
        end
    end,
    
    setCallback = function(self, ecallback, ...)
        if ecallback.name ~= nil then
            self.callback = ecallback
        elseif type(ecallback) == "string" then
            self.callback = callback.get(ecallback)
        end
        
        local newParams = {...}
        if #newParams ~= 0 then
            self.params = params
        end
    end
}

local function new(ename, echannel, ecallback, ...)
    local eventid = 1
    while __events[eventid] ~= nil do
        eventid = eventid + 1
    end
    
    __events[eventid] = setmetatable({}, {__index = __event})
    
    __events[eventid].id = eventid
    __events[eventid].name = ename
    __events[eventid].channel = echannel
    
    if ecallback.name ~= nil then
        __events[eventid].callback = ecallback
    else
        __events[eventid].callback = callback.get(ecallback)
    end
    
    __events[eventid].params = {...}
    
    return __events[eventid]
end
moduleTable.new = new

local function destroy(event)
    if type(event) == "number" then
        table.remove(__events, event)
    elseif type(event) == "table" then
        if event.id ~= nil then
            table.remove(__events, event.id)
        end
        event = nil
    end
end
moduleTable.destroy = destroy

local function getTable(eventid)
    return __events[eventid]
end
moduleTable.getTable = getTable

local function getAll()
    return __events
end
moduleTable.getAll = getAll

return moduleTable

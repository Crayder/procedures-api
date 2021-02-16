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
        return moduleTable.new(self.name, self.channel, self.callback, unpack(self.params))
    end,
    
    call = function(self, ...)
        if self.callback ~= nil and self.callback.name ~= nil then
            if #({...}) > 0 then
                return self.callback:call(self.id, ...)
            else
                return self.callback:call(self.id, unpack(self.params))
            end
        end
        return nil
    end,
    
    queue = function(self, ...)
        if #({...}) > 0 then
            return os.queueEvent(self.name, self.id, self.channel, nil, ...)
        elseif #(self.params) > 0 then
            return os.queueEvent(self.name, self.id, self.channel, nil, unpack(self.params))
        else
            return os.queueEvent(self.name, self.id, self.channel, nil)
        end
    end,
    
    setChannel = function(self, echannel)
        if type(echannel) == "number" then
            self.channel = echannel
        end
    end,
    
    setCallback = function(self, ecallback, ...)
        if ecallback ~= nil and ecallback.name ~= nil then
            self.callback = ecallback
        elseif type(ecallback) == "string" then
            self.callback = callback.get(ecallback)
        end
        
        local newParams = {...}
        if #newParams ~= 0 then
            self.params = newParams
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
    
    if ecallback ~= nil  then
        if ecallback.name ~= nil then
            __events[eventid].callback = ecallback
        else
            __events[eventid].callback = callback.get(ecallback)
        end
    end
    
    __events[eventid].params = {...}
    
    return __events[eventid]
end
moduleTable.new = new

local function destroy(eventid)
    local eve = nil
    if type(eventid) == "number" then
        eve = __events[eventid]
    elseif type(eventid) == "table" then
        eve = eventid
    end
    
    if eve.id ~= nil then
        __events[eve.id].params = nil
        __events[eve.id] = nil
    end
end
moduleTable.destroy = destroy

local function getTable(eventid)
    return __events[eventid]
end
moduleTable.getTable = getTable

local function getIDs()
    local list = {}
    local count = 0
    
    for k,_ in pairs(__events) do
        table.insert(list,k)
        count = count + 1
    end
    
    return list, count
end
moduleTable.getIDs = getIDs

local function count()
    local count = 0
    for _ in pairs(__events) do count = count + 1 end
    return count
end
moduleTable.count = count

return moduleTable

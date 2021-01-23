local moduleTable = {}

local __events = {}
local __event = {
    id = nil, -- event id
    name = nil, -- event name
    channel = nil, -- channel this event would occur with
    callback = nil, -- callback 
    params = nil, -- callback params
    
    -- Returns deep copy of self.
    copy = function(self)
        return new(self.name, self.channel, self.callback, unpack(self.params))
    end,
    
    -- Calls `_.callback:call` with event parameters (event ID, given params or _.params).
    -- Params: `...` (overrides self's params if not nil)
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
    
    -- Queues an event globally, all running procedures should catch it next.
    -- Params: `...` (overrides self's params if not nil)
    queue = function(self, ...)
        if #({...}) > 0 then
            return os.queueEvent(self.name, self.id, self.channel, nil, ...)
        else
            return os.queueEvent(self.name, self.id, self.channel, nil, unpack(self.params))
        end
    end,
    
    setChannel = function(self, newChannel)
        if type(newChannel) == "number" then
            self.channel = newChannel
        end
    end,
    
    setCallback = function(self, newCallback, ...)
        local newParams = {...}
        
        if newCallback.name ~= nil then
            self.callback = newCallback
        elseif type(newCallback) == "string" then -- assume it's a name of an already created callback
            self.callback = callback.get(newCallback)
        end
        
        if #newParams ~= 0 then
            self.params = params
        end
    end
}

-- Creates a new event.
-- Params: event name, sender channel, callback/callback name, params
local function new(ename, echannel, ecallback, ...)
    local eventid = 1
    while self.__events[eventid] ~= nil do
        eventid = eventid + 1
    end
    
    __events[eventid] = setmetatable({}, {__index = __event})
    
    __events[eventid].id = eventid
    __events[eventid].name = ename
    __events[eventid].channel = echannel
    
    if ecallback.name ~= nil then
        __events[eventid].callback = ecallback
    else -- assume it's a name of an already created callback
        __events[eventid].callback = callback.get(ecallback)
    end
    
    __events[eventid].params = {...}
    
    return __events[eventid]
end
moduleTable.new = new

-- Destroys given event/ID.
-- Params: event id or event
local function destroy(e)
    if type(e) == "number" then
        table.remove(__events, e)
    elseif type(e) == "table" then
        if e.id ~= nil then
            table.remove(__events, e.id)
        end
    end
end
moduleTable.destroy = destroy

-- Returns table of given event ID.
-- Params: eventid
local function getTable(eventid)
    return __events[eventid]
end
moduleTable.getTable = getTable

-- Returns list of all event tables.
local function getAll()
    return __events
end
moduleTable.getAll = getAll

return moduleTable

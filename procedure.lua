callback = require("callback")
event = require("event")

local moduleTable = {}

local __procedures = {}
local __procedure = {
    id = nil, -- procedure id
    channel = nil, -- channel used for internal procedure events
    filters = { -- filters, checked in order
        ids = {},
        names = {},
        channels = {},
        timers = {}
    },
    
    getFilterNameIndex = function(self, name)
        if type(name) == "string" then
            for k,v in pairs(self.filters.names) do
                if v == name then
                    return k
                end
            end
        end
        return nil
    end,
    getFilterChannelIndex = function(self, channel)
        if type(channel) == "number" then
            for k,v in pairs(self.filters.channels) do
                if v == channel then
                    return k
                end
            end
        end
        return nil
    end,
    getFilterTimerIndex = function(self, timer)
        if type(timer) == "number" then
            for k,v in pairs(self.filters.timers) do
                if v == timer then
                    return k
                end
            end
        end
        return nil
    end,
    
    -- Add filter for given params, event ID is always checked first so it's likely all you need. Unless working with modem_event's and such.
    -- Notes: Use `nil` for params you won't be adding.
    addFilter = function(self, ids, names, channels, timers)
        local did = false
        
        if names ~= nil then
            if type(names) == "table" and #names ~= 0 then
                for k,v in pairs(names) do
                    if type(v) == "string" then
                        table.insert(self.filters.names, v)
                        did = true
                    end
                end
            elseif type(names) == "string" then
                table.insert(self.filters.names, names)
                did = true
            end
        end
        
        if channels ~= nil then
            if type(channels) == "table" and #channels ~= 0 then
                for k,v in pairs(channels) do
                    if type(v) == "number" then
                        table.insert(self.filters.channels, v)
                        did = true
                    end
                end
            elseif type(channels) == "number" then
                table.insert(self.filters.channels, channels)
                did = true
            end
        end
        
        if timers ~= nil then
            if type(timers) == "table" and #timers ~= 0 then
                for k,v in pairs(timers) do
                    if type(v) == "number" then
                        table.insert(self.filters.timers, v)
                        did = true
                    end
                end
            elseif type(timers) == "number" then
                table.insert(self.filters.timers, timers)
                did = true
            end
        end
        
        return did
    end,
    
    -- Remove filter by registered id.
    -- Params: `filterid` (funcid returned by `addFunction`)
    removeFilter = function(self, ids, names, channels, timers)
        local did = false
        
        if names ~= nil then
            if type(names) == "table" and #names ~= 0 then
                for k,v in pairs(names) do
                    local index = self:getFilterNameIndex(v)
                    if index ~= nil then
                        table.remove(self.filters.names, index)
                    end
                end
            elseif type(names) == "string" then
                local index = self:getFilterNameIndex(names)
                if index ~= nil then
                    table.remove(self.filters.names, index)
                end
            end
        end
        
        if channels ~= nil then
            if type(channels) == "table" and #channels ~= 0 then
                for k,v in pairs(channels) do
                    local index = self:getFilterChannelIndex(v)
                    if index ~= nil then
                        table.remove(self.filters.channels, index)
                    end
                end
            elseif type(channels) == "number" then
                local index = self:getFilterChannelIndex(channels)
                if index ~= nil then
                    table.remove(self.filters.channels, index)
                end
            end
        end
        
        if timers ~= nil then
            if type(timers) == "table" and #timers ~= 0 then
                for k,v in pairs(timers) do
                    local index = self:getFilterTimerIndex(timers)
                    if index ~= nil then
                        table.remove(self.filters.channels, v)
                    end
                end
            elseif type(timers) == "number" then
                local index = self:getFilterTimerIndex(timers)
                if index ~= nil then
                    table.remove(self.filters.channels, index)
                end
            end
        end
    end,
    
    setChannel = function(self, newChannel)
        if type(newChannel) == "number" then
            self.channel = newChannel
        end
    end,
    
    -- Queue an event specifically for this procedure.
    -- Params: event, override params
    -- TODO: scheduleEvent(self, event, ...)
    
    -- Queues an event to be called called specifically for this procedure, this should catch it next.
    queueEvent = function(self, e, ...)
        if #({...}) > 0 then
            self:addFilter(e.id)
            return os.queueEvent(e.name, e.id, e.channel, self.id, ...)
        else
            self:addFilter(e.id)
            return os.queueEvent(e.name, e.id, e.channel, self.id, unpack(e.params))
        end
    end,
    -- Set timer to call an event.
    timerEvent = function(self, e, seconds, repeating)
        e.timer = os.startTimer(seconds)
        self:addFilter(nil, nil, e.timer)
        -- TODO: in listener, if name is "timer", loop through filter ids and see if they have a scheduled time
        return true
    end,
    -- Scheduled an event to be called specifically for this procedure.
    scheduleEvent = function(self, e, seconds, ...)
        e.scheduled = os.clock() + seconds
        self:addFilter(e.id)
        -- TODO: in listener, during the update phase, loop through filter ids and see if they have a scheduled time
        return true
    end
    
    --TODO: in 'start', create a repeating timer event that calls __internalUpdate(self, event id)
}

local function __internalUpdate(procid, eventid)
end

-- Creates a new procedure.
-- Params: procedure port, procedure update rate
local function new(eport, eupdateRate)
    local procid = 1
    while self.__procedures[procid] ~= nil do
        procid = procid + 1
    end
    
    __procedures[procid] = setmetatable({}, {__index = __procedure})
    
    __procedures[procid].id = procid
    
    __procedures[procid].port = eport
    if eport == nil then
        __procedures[procid].port = math.random(1024, 256 * 256 - 1024)
    end
    
    __procedures[procid].updateRate = eupdateRate
    if eupdateRate == nil then
        __procedures[procid].updateRate = 1
    end
    
    return procid
end
moduleTable.new = new

-- Destroys given procedure/ID.
-- Params: procedure id or procedure
local function destroy(e)
    if type(e) == "number" then
        table.remove(__procedures, e)
    elseif type(e) == "table" then
        if e.id ~= nil then
            table.remove(__procedures, e.id)
        end
    end
end
moduleTable.destroy = destroy

-- Returns table of given procedure ID.
-- Params: procedure id
local function getTable(procid)
    return __procedures[procid]
end
moduleTable.getTable = getTable

-- Returns list of all procedure tables.
local function getAll()
    return __procedures
end
moduleTable.getAll = getAll

return moduleTable

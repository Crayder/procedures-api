callback = require("callback")
event = require("event")

local moduleTable = {}

local __procedures = {}
local __procedure = {
    id = nil, -- procedure id
    channel = nil, -- channel used for internal procedure events
    filters = {
        names = {},
        channels = {},
        timers = {}
    },
    
    -- Add filter for given params.
    -- Notes: Use `nil` for params you won't be adding.
    addFilter = function(self, names, channels, timers)
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
    
    -- Remove filter by registered id.
    -- Params: `filterid` (function id returned by `addFunction`)
    removeFilter = function(self, names, channels, timers)
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
    -- TODO: scheduleEvent = function(self, event, ...)
    
    -- Queues an event specifically for this procedure, this should catch it next.
    queueEvent = function(self, e, ...)
        if #({...}) > 0 then
            return os.queueEvent(e.name, e.id, e.channel, self.id, ...)
        else
            return os.queueEvent(e.name, e.id, e.channel, self.id, unpack(e.params))
        end
    end
}

-- Creates a new procedure.
-- Params: procedure port, procedure update rate
function new(eport, eupdateRate)
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

-- Returns table of given procedure ID.
-- Params: procedure id
local function get(procid)
    return __procedures[procid]
end
moduleTable.get = get

-- Destroys given procedure/ID.
-- Params: procedure id or procedure
local function destroy(e)
    if type(e) == "number" then
        __procedures[e] = nil
    else
        e = nil
    end
end
moduleTable.destroy = destroy

return moduleTable

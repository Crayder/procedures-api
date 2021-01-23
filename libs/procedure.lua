callback = require("callback")
event = require("event")

local moduleTable = {}

local __procedures = {}
local __procedure = {
    id = nil, -- procedure id
    channel = nil, -- channel used for internal procedure events
    filters = { -- filters, checked in order
        --names = {},
        --channels = {},
        events = {},
        timers = {},
        scheduled = {}
    },
    
    isRunning = false,
    continueRunning = false,
    
    setChannel = function(self, newChannel)
        if type(newChannel) == "number" then
            self.channel = newChannel
        end
    end,
    
    -- TODO: addQueueEvent, to add events already queued by event:queue.
    -- Queues an event to be called called specifically for this procedure, this should catch it next.
    queueEvent = function(self, e, ...)
        self.filters.events[e.id] = {event = e, params = {...}}
        
        if #({...}) > 0 then
            return os.queueEvent(e.name, e.id, e.channel, self.id, ...)
        else
            return os.queueEvent(e.name, e.id, e.channel, self.id, unpack(e.params))
        end
    end,
    -- TODO: cancelQueueEvent - simply remove it from the filters
    
    -- TODO: addTimerEvent, to add an already created timer and assign an event
    -- Set timer to call an event.    
    timerEvent = function(self, e, secs, repeated, ...)
        local timerid = os.startTimer(secs)
        self.filters.timers[timerid] = {event = e, seconds = secs, repeating = repeated, params = {...}}
        
        -- TODO: in listener, if name is "timer", loop through filter ids and see if they have a scheduled time
        return timerid
    end,
    -- TODO: cancelTimerEvent - simply remove it from the filters
    
    -- Scheduled an event to be called specifically for this procedure.
    scheduleEvent = function(self, e, secs, repeated, ...)
        local scheduledID = 1
        while self.filters.scheduled[scheduledID] ~= nil do
            scheduledID = scheduledID + 1
        end
        
        self.filters.scheduled[scheduledID] = {event = e, seconds = secs, time = (os.clock() + secs), repeating = repeated, params = {...}}
        
        -- TODO: in listener, during the update phase, loop through scheduled filters and check for this one's time
        return scheduledID
    end,
    -- TODO: cancelScheduledEvent - simply remove it from the filters
    
    --TODO: in 'start', create a repeating timer event that calls __internalUpdate(self, event id)
    start = function(self)
        self.isRunning = true
        
        local updateEvent = nil
        local updateTimer = nil
        local updateCallbackName = ("internalUpdate_"..self.id)
        local updateCallback = callback.register(updateCallbackName, function()
            table.remove(self.filters.timers, updateTimer)
            
            if self.continueRunning then
                if #self.filters.scheduled > 0 then
                    local currentTime = os.clock()
                    for k,v in pairs(self.filters.scheduled) do
                        if v.time <= currentTime then
                            self:queueEvent(v.event, unpack(v.params))
                            
                            if v.repeating then
                                self.filters.scheduled[k].time = (os.clock() + v.seconds)
                            else
                                table.remove(self.filters.scheduled, k)
                            end
                        end
                    end
                end
                
                updateTimer = self:timerEvent(updateEvent, 1)
            end
        end)
        updateEvent = event.new("e_internalUpdate_"..self.id, self.channel, updateCallback)
        updateTimer = self:timerEvent(updateEvent, 1)
        
        local stopCallback = callback.register("internalStop_"..self.id, function()
            self.continueRunning = false
        end)
        self.__stopEvent = event.new("e_internalStop_"..self.id, self.channel, stopCallback)
        
        self.continueRunning = true
        while self.continueRunning do
            local event = {os.pullEvent()}
            
            if self.continueRunning then
                if event[1] == "timer" then
                    local v = self.filters.timers[data[2]]
                    if v ~= nil then
                        self:queueEvent(v.event, unpack(v.params))
                        
                        if v.repeating then
                            self:timerEvent(v.event, v.seconds, v.repeating, unpack(v.params))
                        end
                        table.remove(self.filters.timers, data[2])
                    end
                elseif type(event[2]) == "number" then
                    local v = self.filters.events[event[2]]
                    if v ~= nil and event[1] == v.event.name then
                        -- # if not checking channel, or event is global (nil),
                        --      or event channel matches channel, or procedure channel matches channel
                        if (event[3] == nil or v.event.channel == nil or event[3] == v.event.channel or event[4] == self.id) then
                            self:queueEvent(v.event, unpack(v.params))
                            table.remove(self.filters.events, k)
                        end
                    end
                end
            end
        end
        
        callback.unregister(updateCallback)
        callback.unregister(stopCallback)
        event.destroy(updateEvent)
        event.destroy(self.__stopEvent)
        
        self.isRunning = false
    end,
    
    __stopEvent = nil,
    stop = function(self)
        if self.isRunning then
            self:queueEvent(self.__stopEvent)
        end
    end
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

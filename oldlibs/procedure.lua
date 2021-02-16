event = require("event")

local moduleTable = {}

local __procedures = {}
local __procedure = {
    id = nil, -- procedure id
    channel = nil, -- channel used for internal procedure events
    filters = { -- filters, checked in order
        events = {}, -- {event table, params table}
        timers = {}, -- {event table, seconds, repeating boolean, params table}
        scheduled = {} -- {event table, seconds, time scheduled, repeating boolean, params table}
    },
    
    -- TODO: Possibly add "childProcedures", a table of procedures created to be ran when this one is, simultaneously to it.
    
    isRunning = false,
    continueRunning = false,
    
    setChannel = function(self, newChannel)
        if type(newChannel) == "number" then
            self.channel = newChannel
        end
    end,
    
    queueEvent = function(self, e, ...)
        if self.filters.events[e.id] == nil then
            self.filters.events[e.id] = {}
        end
        
        local index = #(self.filters.events[e.id]) + 1
        if #({...}) > 0 then
            self.filters.events[e.id][index] = {event = e, params = {...}}
            e:queue(self.id, ...)
        else
            self.filters.events[e.id][index] = {event = e, params = {unpack(e.params)}}
            e:queue(self.id, unpack(e.params))
        end
        return index
    end,
    addQueueEvent = function(self, e, ...)
        -- TODO: addQueueEvent, to add events already queued by event:queue or expected to be (like a rednet_message maybe).
    end,
    cancelQueueEvent = function(self, e, queuedid)
        if type(e) == "table" and e.id ~= nil and self.filters.events[e.id][queuedid] ~= nil then
            if self.filters.events[e.id][queuedid].params ~= nil then
                self.filters.events[e.id][queuedid].params = nil
            end
            self.filters.events[e.id][queuedid] = nil
        end
    end,
    
    timerEvent = function(self, e, secs, repeated, ...)
        local timerid = os.startTimer(secs)
        self.filters.timers[timerid] = {event = e, seconds = secs, repeating = repeated, params = {...}}
        
        return timerid
    end,
    addTimerEvent = function(self, e, secs, repeated, ...)
        -- TODO: addTimerEvent, to add an already created timer and assign an event
    end,
    cancelTimerEvent = function(self, timerid)
        if self.filters.timers[timerid] ~= nil then
            if self.filters.timers[timerid].params ~= nil then
                self.filters.timers[timerid].params = nil
            end
            self.filters.timers[timerid] = nil
        end
    end,
    
    scheduleEvent = function(self, e, secs, repeated, ...)
        local scheduledID = 1
        while self.filters.scheduled[scheduledID] ~= nil do
            scheduledID = scheduledID + 1
        end
        
        self.filters.scheduled[scheduledID] = {event = e, seconds = secs, time = (os.clock() + secs), repeating = repeated, params = {...}}
        
        return scheduledID
    end,
    cancelScheduledEvent = function(self, schedid)
        if self.filters.scheduled[schedid] ~= nil then
            if self.filters.scheduled[schedid].params ~= nil then
                self.filters.scheduled[schedid].params = nil
            end
            self.filters.scheduled[schedid] = nil
        end
    end,
    
    start = function(self, updateHook)
        logg("set running")
        self.isRunning = true
        
        logg("set update stuff")
        local updateEvent = nil
        local updateTimer = nil
        local updateCallbackName = ("internalUpdate_"..self.id)
        local updateCallback = callback.register(updateCallbackName, updateHook, function()
            logg("update called")
            table.remove(self.filters.timers, updateTimer)
            
            if self.continueRunning then
                if #self.filters.scheduled > 0 then
                    logg("update checking scheduled")
                    local currentTime = os.clock()
                    for k,v in pairs(self.filters.scheduled) do
                        if v.time <= currentTime then
                            logg("update scheduled found")
                            self:queueEvent(v.event, unpack(v.params))
                            
                            if v.repeating then
                                logg("update scheduled reset")
                                self.filters.scheduled[k].time = (os.clock() + v.seconds)
                            else
                                logg("update scheduled removed")
                                table.remove(self.filters.scheduled, k)
                            end
                        end
                    end
                end
                
                logg("update reset")
                updateTimer = self:timerEvent(updateEvent, 1)
            end
        end)
        logg("update create and make event timer")
        updateEvent = event.new("e_internalUpdate_"..self.id, self.channel, updateCallback)
        updateTimer = self:timerEvent(updateEvent, 1)
        
        logg("set stop stuff")
        local stopCallback = callback.register("internalStop_"..self.id, function()
            logg("stop called")
            self.continueRunning = false
        end)
        self.__stopProcedure = event.new("e_internalStop_"..self.id, self.channel, stopCallback)
        
        logg("set continueRunning and start")
        self.continueRunning = true
        while self.continueRunning do
            logg("pulling...", 1)
            local event = {os.pullEvent()}
            for k,v in pairs(self.filters.timers) do
                logg("stuff ("..k.."): "..v.event.name, 1)--textutils.serialize(v), 1)
                --sleep(5)
            end
            logg("event: "..textutils.serialize(event), 1)
            --sleep(5)
                        
            if self.continueRunning then
                logg("checking queued and timers")
                if event[1] == "timer" then
                    logg("is timer")
                    local f = self.filters.timers[event[2]]
                    if f ~= nil then
                        logg("valid timer")
                        self:queueEvent(f.event, unpack(f.params))
                        
                        if f.repeating then
                            logg("timer reset")
                            self:timerEvent(f.event, f.seconds, f.repeating, unpack(f.params))
                        end
                        table.remove(self.filters.timers, event[2])
                    end
                elseif type(event[2]) == "number" then
                    logg("has potential number")
                    local f = self.filters.events[event[2]]
                    if f ~= nil then
                        logg("valid event queue "..event[2])
                        for k,v in pairs(f) do
                            if event[1] == v.event.name then
                                logg("valid event name found: id "..v.event.id)
                                -- # if not checking channel, or event is global (nil),
                                --      or event channel matches channel, or procedure channel matches channel
                                if (event[3] == nil or v.event.channel == nil or event[3] == v.event.channel or event[4] == self.id) then
                                    logg("valid event channel found")
                                    self:queueEvent(v.event, unpack(v.params))
                                    table.remove(f, k)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        logg("unregistering callbacks")
        callback.unregister(updateCallback)
        callback.unregister(stopCallback)
        logg("unregistering event")
        event.destroy(updateEvent)
        event.destroy(self.__stopProcedure)
        
        logg("unset isRunning")
        self.isRunning = false
    end,
    
    __stopProcedure = nil,
    stop = function(self)
        logg("manual stop called")
        if self.isRunning then
            self:queueEvent(self.__stopProcedure)
        end
    end
}

LOG_PRINT_LEVEL = 0
LOG_EXPORT_LEVEL = 0
function logg(str, doit)
    if LOG_PRINT_LEVEL == 0 or (doit ~= nil and doit >= LOG_PRINT_LEVEL) then
        print(str)
    end
    if LOG_EXPORT_LEVEL == 0 or (doit ~= nil and doit >= LOG_EXPORT_LEVEL) then
        file = fs.open("log.txt", "a")
        file.writeLine(str)
        file.close()
    end
    --sleep(0.1)
end

local function new(echannel)
    local procid = 1
    while __procedures[procid] ~= nil do
        procid = procid + 1
    end
    
    __procedures[procid] = setmetatable({}, {__index = __procedure})
    
    __procedures[procid].id = procid
    
    if echannel == nil then
        __procedures[procid].channel = math.random(1024, 256 * 256 - 1024)
    else
        __procedures[procid].channel = echannel
    end
    
    return __procedures[procid]
end
moduleTable.new = new

local function destroy(proc)
    if type(proc) == "number" then
        proc = moduleTable.getTable(proc)
    end
    
    if type(proc) == "table" then
        if proc.id ~= nil then
            if proc.isRunning then
                v.__stopProcedure:call()
            end
            
            table.remove(__procedures, proc.id)
        end
    end
end
moduleTable.destroy = destroy

function start(...)
    local procs = {...}
    local funcs = {}
    for k,v in pairs(procs) do
        if v.id ~= nil and v.isRunning == false then
            funcs[k] = function()
                v:start()
            end
        end
    end
    
    parallel.waitForAll(unpack(funcs))
end
moduleTable.start = start

function stop(...)
    local procs = {...}
    for k,v in pairs(procs) do
        if v.id ~= nil and v.isRunning == true then
            v.__stopProcedure:call()
        end
    end
end
moduleTable.stop = stop

local function getTable(procid)
    return __procedures[procid]
end
moduleTable.getTable = getTable

local function getIDs()
    local list = {}
    local count = 0
    
    for k,_ in pairs(__procedures) do
        table.insert(list,k)
        count = count + 1
    end
    
    return list, count
end
moduleTable.getIDs = getIDs

local function count()
    local count = 0
    for _ in pairs(__procedures) do count = count + 1 end
    return count
end
moduleTable.count = count

return moduleTable

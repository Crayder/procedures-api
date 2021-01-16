local __selected = nil
local __indexes = {}

local procedure = {
    --__internalID = 1,
    --__internalPort = 1,
    --__internalUpdateRate = 1,
    
    __callbacks = {},
    __events = {},
    -- __callbacks will be an array of callback names added by the script, for events to call.
    -- __events will be an array of events added by the script, to be watched for.
    --[[ 
        structure of self.__events item
        {
            ['expected_event'] = expected_event,
            ['expected_sender'] = expected_sender,
            ['callback_name'] = "callback_name",
            ['callback_params'] = {callback params},
            ['remove_after'] = true/false
            ['timed_seconds'] = timed_seconds
            ['scheduled_time'] = timed_seconds
        }
    --]]

    __doEventCheck = true,
    
    ----------
    
    running = false,
    
    ----------
    
    registerCallback = function(self, name, func)
        --print("self:registerCallback("..name..")")
        
        if self.__callbacks[name] == nil then
            self.__callbacks[name] = {}
        end
        
        local new_id = 1
        while self.__callbacks[name][new_id] ~= nil do
            new_id = new_id + 1
        end
        
        self.__callbacks[name][new_id] = func
        
        return new_id
    end,
    unregisterCallback = function(self, name, id)
        --print("self:unregisterCallback("..name..", "..id..")")
        if self.__callbacks[name] then
            self.__callbacks[name][id] = nil
            
            if #self.__callbacks[name] == 0 then
                self.__callbacks[name] = nil
            end
            
            return true
        end
        return nil
    end,

    ----------

    -- event is either an index (timer id) or string ("timer", "modem_event")
    registerEvent = function(self, event, senderPort, onetime, callback, ...)
        local new_id = 1
        while self.__events[new_id] ~= nil do
            new_id = new_id + 1
        end
        --print("self:registerEvent("..new_id..")")
        
        self.__events[new_id] = {}
        self.__events[new_id].expected_event = event
        self.__events[new_id].expected_sender = senderPort
        self.__events[new_id].callback_name = callback
        self.__events[new_id].callback_params = {...}
        self.__events[new_id].remove_after = onetime
        
        return new_id
    end,
    
    registerQueuedEvent = function(self, event, senderPort, onetime, callback, ...)
        local new_id = self:registerEvent(event, senderPort, onetime, callback, ...)
        self:queueEvent(event)
        return new_id
    end,
    registerScheduledEvent = function(self, event, senderPort, seconds, callback, ...)
        local new_id = self:registerEvent(event, senderPort, true, callback, ...)
        self.__events[new_id].scheduled_time = os.clock() + seconds
        return new_id
    end,
    registerTimedEvent = function(self, seconds, senderPort, onetime, callback, ...)
        local new_id = self:registerEvent(os.startTimer(seconds), senderPort, onetime, callback, ...)
        self.__events[new_id].timed_seconds = seconds
        return new_id
    end,
    
    unregisterEvent = function(self, eventid)
        --print("self.unregisterEvent("..eventid..")")
        if self.__events[eventid] then
            self.__events[eventid] = nil
            return true
        end
        return nil
    end,

    ----------
    
    queueEvent = function(self, event, senderPort)
        --print("self:queueEvent("..event..")")
        if type(event) == "string" then
            os.queueEvent(event, nil, senderPort)
            return true
        end
        return nil
    end,
    queueEventID = function(self, eventid)
        --print("self:queueEvent("..event..")")
        if self.__events[eventid] then
            return self:queueEvent(self.__events[eventid].expected_event, self.__events[eventid].expected_sender)
        end
        return nil
    end,

    ----------

    getEventData = function(self, eventid, dataName)
        if self.__events[eventid] then
            return self.__events[eventid][dataName]
        end
        return nil
    end,
    setEventData = function(self, eventid, dataName, value)
        if self.__events[eventid] then
            self.__events[eventid][dataName] = value
            return true
        end
        return nil
    end,

    ----------

    -- must be called to begin
    start = function(self)
        --print("start")
        self.running = true
        
        local stopCall = self:registerCallback("__stopProc", self.__stopProc)
        local stopEvent = self:registerEvent("gorton_stopcoroutine", self.__internalPort, true, "__stopProc")
        
        self.__doEventCheck = true
        local updateCall = self:registerCallback("__internalUpdate", self.__internalUpdate)
        self:registerEvent(os.startTimer(self.__internalUpdateRate), self.__internalPort, true, "__internalUpdate")
        
        while self.__doEventCheck do
            --print("self.__doEventCheck")
            --       timer | event, id
            -- modem_event | event, side, frequency, replyFrequency, message, distance
            
            local event = {os.pullEvent()}
            for k,v in pairs(self.__events) do
                if (type(v.expected_event) == "string" and v.expected_event == event[1]) then
                    if v.expected_sender == nil or v.expected_sender == event[3] then
                        --if v.run_after_tick == nil or v.run_after_tick <= os.clock() then
                            --print("expected_event = string ("..v.expected_event..")")
                            self:__event_call(k, event)
                            break
                        --end
                    end
                elseif event[1] == "timer" and v.expected_event == event[2] then
                    --print("expected_event = update time")
                    self:__event_call(k, event)
                    break
                end
            end
        end
        
        self:unregisterCallback("__stopProc", stopCall)
        self:unregisterCallback("__internalUpdate", updateCall)
        
        self.running = false
    end,

    -- this must be called DURING coroutine FROM an event
    stop = function(self)
        self:queueEvent("gorton_stopcoroutine", self.__internalPort)
    end,

    -- this must be called DURING coroutine FROM an event
    reset = function(self)
        self.__callbacks = {}
        self.__events = {}
        self.__doEventCheck = true
    end,

    ----------

    -- takes __events ID and passed event data from pullEvent
    __event_call = function(self, eventid, eventdata)
        --print("self:__event_call("..eventid..")")
        local tmpEvent = self.__events[eventid] -- since this could technically be called after coroutine is stopped, needs saved here
        local eventFuncs = self.__callbacks[tmpEvent.callback_name]
        if eventFuncs ~= nil then
            if type(eventFuncs) ~= "table" then
                eventFuncs = {eventFuncs}
            end
            for k,func in pairs(eventFuncs) do
                --print("params: "..textutils.serialize(tmpEvent.callback_params))
                if tmpEvent.callback_params ~= nil then
                    -- TODO: ensure this "tmpEvent.expected_sender == self.__internalPort" check is actually needed.
                    if tmpEvent.expected_sender == self.__internalPort then func(self, eventdata, unpack(tmpEvent.callback_params))
                    else func(eventdata, unpack(tmpEvent.callback_params))
                    end
                else
                    if tmpEvent.expected_sender == self.__internalPort then func(self, eventdata)
                    else func(eventdata)
                    end
                end
            end
            if tmpEvent.remove_after then
                self:unregisterEvent(eventid)
            elseif type(tmpEvent.expected_event) == "number" then
                -- start the timer back over.
                tmpEvent.expected_event = os.startTimer(tmpEvent.timed_seconds)
            end
        end
    end,

    ----------

    -- other modules can hook into this with registerCallback("__internalUpdate", functionName)
    __internalUpdate = function(self)
        --print("__internalUpdate")
        
        local currTime = os.clock()
        for k,v in pairs(self.__events) do
            if v.scheduled_time ~= nil and v.scheduled_time <= currTime then
                self:queueEventID(k)
            end
        end
        
        if self.__doEventCheck then
            self:registerEvent(os.startTimer(self.__internalUpdateRate), self.__internalPort, true, "__internalUpdate")
        end
    end,
    __stopProc = function(self)
        --print("__stopProc")
        self.__doEventCheck = false
    end
}

function new(port, updateRate)
    local internalID = 1
    while __indexes[internalID] ~= nil do internalID = internalID + 1 end
    
    local internalPort = port
    if internalPort == nil then internalPort = (os.getComputerID() + 1601) end
    
    local internalUpdateRate = updateRate
    if internalUpdateRate == nil then internalUpdateRate = 1 end
    
    local data = {
        __internalID = internalID,
        __internalPort = internalPort,
        __internalUpdateRate = internalID
    }
    setmetatable(data, {__index = procedure})
    return data
end
function destroy(...)
    local procs = {...}
    for k,v in pairs(procs) do
        if v.__internalID ~= nil then
            if v.running then
                v.stop(v)
                sleep(0.01) -- an extra event just in case
            end
            
            __indexes[v.__internalID] = nil
            v = nil
        end
    end
end

function start(...)
    local procs = {...}
    local funcs = {}
    for k,v in pairs(procs) do
        funcs[k] = function()
            v.start(v)
        end
    end
    
    parallel.waitForAll(unpack(funcs))
end

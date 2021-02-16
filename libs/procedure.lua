local moduleTable = {}

moduleTable.list = {} -- < 'internal' list of procedure tables

local __procedure = {
    id = nil,
    
    listenerIDs = {},
    listeners = {
        --[[ ex/doc
        ["event_name"] = {  name of the event to be detected by os.pullEvent, ex "timer" or "modem_message"
            [1] = {
                callback =  callback index or function reference
                enabled =   true if listener should watch for this, false if it should be ignored for any reason
                seconds =   null if mode not a repeating timer/alarm, length of time to reset to if repeating
                timer = id
                alarm = id
                repeating = true/false
            }
        }
        --]]
    },
    
    running = false,
    internalListeners = {},
    
    start = function(self)
        if not self.running then
            -- $ create the runtime events here, like the internal update timer and rpc detector:
            internalListeners[self:onInterval(1, function()
                -- TODO: TESTS: ensure this is called every second as long as this procedure is running
                os.queueEvent("procedure_tick")
            end)] = true
            internalListeners[self:onModemMessage(function(side, frequency, replyFrequency, message, distance)
                -- TODO: this receives "procedure_rpc". need a way to send them as well.
                local rpc = textutils.unserialize(message)
                if type(rpc) == "table" and rpc[1] == "procedure_rpc" then
                    --[[ message will have this structure {
                        [1] = "procedure_rpc" -- constant string to detect rpc's
                        [2] = name - RPC name
                        [3] = sender - Sender's computer ID
                        [4] = channel - To be used for sending to specific servers or servers listening to a channel
                        [5] = data - anything else that the procedure type requires
                    }--]]
                    table.remove(rpc, 1)
                    os.queueEvent("procedure_rpc_received", frequency, replyFrequency, distance, unpack(rpc))
                end
            end, true)] = true
            
            self.running = true
            __event_loop_tick(self, "procedure_started", self.id)
            
            while self.running do
                __event_loop_tick(self, os.pullEventRaw())
            end
            return true
        end
        return false
    end,
    
    stop = function(self)
        if self.running then
            for k,v in pairs(internalListeners) do
                self.removeListener(k)
                -- TODO: TESTS: ensure this removes internal listeners
            end
            
            __event_loop_tick(self, "procedure_stopped", self.id)
            self.running = false
            return true
        end
        return false
    end,
    
    onEvent = function(self, eventName, callback, repeating) return __registerEventListener(self, eventName, nil, ((repeating ~= 0 and repeating) and 1 or 0), callback) end,
    oneEvent = function(self, eventName, callback) return __registerEventListener(self, eventName, nil, false, callback) end,
    
    onTimeout = function(self, seconds, callback) return __registerEventListener(self, "timer", seconds, nil, callback) end,
    onInterval = function(self, seconds, callback) return __registerEventListener(self, "timer", seconds, true, callback) end,
    onTimer = function(self, seconds, repeating, callback) return __registerEventListener(self, "timer", seconds, repeating, callback) end,
    onAlarm = function(self, daytime, repeating, callback) return __registerEventListener(self, "alarm", daytime, true, callback) end,
    
    -- # calls callback with: char
    onChar = function(self, callback, repeating) return __registerEventListener(self, "char", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: keycode, holding
    onKeyDown = function(self, callback, repeating) return __registerEventListener(self, "key", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: keycode
    onKeyUp = function(self, callback, repeating) return __registerEventListener(self, "key_up", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: button, x, y
    onMouseDown = function(self, callback, repeating) return __registerEventListener(self, "mouse_click", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: button, x, y
    onMouseUp = function(self, callback, repeating) return __registerEventListener(self, "mouse_up", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: direction, x, y
    onMouseWheel = function(self, callback, repeating) return __registerEventListener(self, "mouse_scroll", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: button, x, y
    onMouseDrag = function(self, callback, repeating) return __registerEventListener(self, "mouse_drag", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side, x, y
    onMonitorTouch = function(self, callback, repeating) return __registerEventListener(self, "monitor_touch", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side, freq, replyFreq, message, distance
    onModemMessage = function(self, callback, repeating) return __registerEventListener(self, "modem_message", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: senderid, message, protocol
    onRednetMessage = function(self, callback, repeating) return __registerEventListener(self, "rednet_message", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: N/A
    onRedstoneSignal = function(self, callback, repeating) return __registerEventListener(self, "redstone", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: N/A
    onTerminate = function(self, callback, repeating) return __registerEventListener(self, "terminate", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side
    onDiskMount = function(self, callback, repeating) return __registerEventListener(self, "disk", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side
    onDiskEject = function(self, callback, repeating) return __registerEventListener(self, "disk_eject", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side
    onPeripheralAttach = function(self, callback, repeating) return __registerEventListener(self, "peripheral", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # calls callback with: side
    onPeripheralDetach = function(self, callback, repeating) return __registerEventListener(self, "peripheral_detach", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    
    -- # (called when the procedure is started) calls with: this procedure id
    onStarted = function(self, callback, repeating) return __registerEventListener(self, "procedure_started", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # (called when the procedure is stopped) calls with: this procedure id
    onStopped = function(self, callback, repeating) return __registerEventListener(self, "procedure_stopped", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # (called after each internal tick) calls with: this procedure id
    onTick = function(self, callback, repeating) return __registerEventListener(self, "procedure_tick", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    -- # (called when the procedure detects an RPC) calls with: this procedure id
    onRPC = function(self, callback, repeating) return __registerEventListener(self, "procedure_rpc_received", nil, ((repeating == nil or not repeating) and 0 or 1), callback) end,
    
    -- TODO: onScheduled (like setAlarm, but using os.clock instead of os.time): sheduledid
        -- would check scheduled times during the onTick timer
            -- if one is found to have expired, call assigned callback and remove
            
    queueEvent = function(self, eventName, ...) return os.queueEvent(eventName, ...) end,
    
    -- creates listener and queues the event once. TODO: make non-repeating events automatically remove themselves after running in the tick.
    doEvent = function(self, eventName, callback, ...)
        self:oneEvent(eventName, callback)
        self:queueEvent(eventName, ...)
    end,
    
    
    removeListener = function(self, index)
        if self.listenerIDs == nil or self.listenerIDs[index] == nil then return nil end
        
        if self.listenerIDs[index] == "timer" then
            os.cancelTimer(self.listeners["timer"][index].timer)
        elseif self.listenerIDs[index] == "alarm" then
            os.cancelTimer(self.listeners["alarm"][index].alarm)
        end
        
        self.listeners[self.listenerIDs[index]][index] = nil
        self.listenerIDs[index] = nil
        
        return true
    end,
    
    disableListener = function(self, index)
        if self.listenerIDs == nil or self.listenerIDs[index] == nil then return nil end
        if internalListeners[index] ~= nil then return nil end -- $ don't enable/disable internal listeners
        
        if self.listenerIDs[index] == "timer" or self.listenerIDs[index] == "alarm" then
            -- TODO: instead of removing the timer, possibly make timer get cancelled and allow re-enabling them as if they were being reset. If so, for non repeating still do the remove.
            -- For now, disabled timers and alarms are simply deleted
            return self:removeListener(index)
        end
        
        self.listeners[self.listenerIDs[index]][index].enabled = false
        return true
    end,
    
    enableListener = function(self, index)
        if self.listenerIDs == nil or self.listenerIDs[index] == nil then return nil end
        if internalListeners[index] ~= nil then return nil end -- $ don't enable/disable internal listeners
        
        if self.listenerIDs[index] == "timer" or self.listenerIDs[index] == "alarm" then
            return false
        end
        
        self.listeners[self.listenerIDs[index]][index].enabled = true
        return true
    end
}

local function __event_loop_tick(self, eventName, ...) -- scanning of pulled event
    eventListeners = self.listeners[eventName]
    --[[eventListeners = {
        callback =  callback index or function reference
        enabled =   true if listener should watch for this, false if it should be ignored for any reason
        seconds =   null if mode not a repeating timer/alarm, length of time to reset to if repeating
        timer = id
        alarm = id
        repeating = true/false
    }--]]
    
    if eventListeners == nil then
        return false
    end
    
    local params = {...}
    
    local doTheCall = function(v, params)
        if type(v.callback) == "function" then
            return v.callback(unpack(params))
        elseif type(v.callback) == "table" and v.callback.name ~= nil then
            return v.callback:call(unpack(params))
        end
    end
    
    --local eventListenersCopy = {unpack(eventListeners)}
    for k,v in pairs(eventListeners) do
        if v.enabled then
            local timedRet = (0x7FFFFFFFFFFFFFFF) -- 0x7FFFFFFFFFFFFFFF because int max is highly unlikely
            if eventName == "timer" and v.timer ~= nil and params[1] == v.timer then
                if v.repeating then
                    v.timer = os.startTimer(v.seconds)
                end
                timedRet = doTheCall(v, params)
            elseif eventName == "alarm" and v.alarm ~= nil and params[1] == v.alarm then
                if v.repeating then
                    v.timer = os.setAlarm(v.seconds)
                end
                timedRet = doTheCall(v, params)
            else
                doTheCall(v, params)
            end
            
            if not v.repeating then
                -- TODO: TESTS: test and ensure this safely removes, if not use eventListenersCopy
                self:removeListener(k)
                -- TODO: maybe add an option to change the default action for non-repeating events, enabling users to make this do self:disableListener instead of self:removeListener
            end
            
            if timedRet ~= (0x7FFFFFFFFFFFFFFF) then
                return timedRet
            end
        end
    end
end

local function __registerEventListener(proc, eventName, seconds, repeating, callback)
    if (eventName == "timer" or eventName == "alarm") and (type(seconds) ~= "integer" or seconds == 0) then
        return nil
    elseif repeating ~= nil and type(repeating) ~= "boolean" and type(repeating) ~= "integer" then
        return nil
    elseif type(callback) ~= "function" or callback.id == nil then
        return nil
    end
    
    if repeating ~= nil and repeating ~= 0 then
        repeating = true
    else
        repeating = false
    end
    
    if proc[eventName] == nil then
        proc[eventName] = {}
    end
    
    local index = 1
    while proc.listenerIDs[index] ~= nil do
        index = index + 1
    end
    proc.listenerIDs[index] = eventName
    
    proc[eventName][index].callback = callback
    proc[eventName][index].enabled = true
    proc[eventName][index].seconds = seconds
    proc[eventName][index].repeating = repeating
    
    if eventName == "timer" then
        proc[eventName][index].timer = os.startTimer(seconds)
    elseif eventName == "alarm" then
        proc[eventName][index].alarm = os.startAlarm(seconds)
    end
    
    return index
end

-- this is basically an alternative to creating a procedure, setting it up, then having to run and destroy it
moduleTable.run = function(func)
    -- TODO: all of this
    -- create a procedure, store it's id: bleh = procedure.new
    -- call func with procedure table: func(procedure.getTable(id))
        -- this will make it so that listeners can be added before running the procedure
    -- procedure:start()
    -- destroy procedure: procedure.destroy(bleh)
    
    --[[ ex.
        tempProcedureSetup = function(proc)
            proc:onInterval(1, function()
                print("called every second")
            end)
            proc:onTimeout(5, function()
                print("called once after 5 seconds, stops procedure")
                proc:stop()
            end)
        end
        procedure.run(tempProcedureSetup)
    --]]
end
-- TODO: Line 101: function await(func, ...)

moduleTable.new = function()
    local procid = 1
    while moduleTable.list[procid] ~= nil do
        procid = procid + 1
    end
    
    __procedures[procid] = setmetatable({}, {__index = __procedure})
    
    __procedures[procid].id = procid
    
    return __procedures[procid]
end

moduleTable.destroy = function(proc)
    -- destroy a procedure if in moduleTable.list
    
    if type(proc) == "number" then
        proc = moduleTable.getTable(proc)
    end
    
    if type(proc) == "table" then
        if proc.id ~= nil and moduleTable.list[proc.id] ~= nil then
            if proc.running then
                proc:stop()
            end
            
            table.remove(moduleTable.list, proc.id)
        end
    end
end

moduleTable.start = function(...)
    procs = {...}
    for _,proc in procs do
        local tmp = 0
        if type(proc) == "number" then
            tmp = moduleTable.getTable(proc)
        elseif type(tmp) == "table" then
            tmp = proc
        end
        
        if type(tmp) == "table" then
            if tmp.id ~= nil and moduleTable.list[tmp.id] ~= nil then
                if tmp.running then
                    tmp:stop()
                end
            end
        end
    end
end

moduleTable.stop = function(proc)
    if type(proc) == "number" then
        proc = moduleTable.getTable(proc)
    end
    
    if type(proc) == "table" then
        if proc.id ~= nil and moduleTable.list[proc.id] ~= nil then
            if proc.running then
                proc:stop()
            end
        end
    end
end

--[[ 

TODO: moduleTable.start = function(...)
    -- start one or more procedures simultaneously
end

TODO: moduleTable.stop = function(...)
    -- stop one or more procedures simultaneously
end

--]]

moduleTable.getTable = function(id)
    return moduleTable.list[id]
end

moduleTable.getList = function()
    local list = {}
    local count = 0
    
    for k,_ in pairs(moduleTable.list) do
        table.insert(list,k)
        count = count + 1
    end
    
    return list, count
end

moduleTable.count = function()
    local count = 0
    for _ in pairs(moduleTable.list) do count = count + 1 end
    return count
end

return moduleTable

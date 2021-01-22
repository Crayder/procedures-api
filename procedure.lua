callback = require("callback")
event = require("event")

local moduleTable = {}

local __procedures = {}
local __procedure = {
    id = nil, -- procedure id
    channel = nil, -- channel used for internal procedure events
    updateRate = nil, -- rate of internal update timer
    
    -- TODO: Should this really be "filters", instead of just checking for `event`'s?
    
    -- each `filters` index is expected data for os.pullEvent
    filters = {},
    
    -- Add filter for given params.
    -- Params: `...` (data for os.pullEvent) (or an event to pull the data from)
    -- Notes: Use `nil` for params you won't be sure of.
    addFilter = function(self, ...)
        local filterid = 1
        while self.filters[filterid] ~= nil do
            filterid = filterid + 1
        end
        
        local params = {...}
        local data = {}
        if #params == 1 and params[1].id ~= nil then
            data = {"gorton_event", params[1].name, params[1].id, procid, ...}
        end
        self.filters[filterid] = data
        
        return filterid
    end,
    
    -- Remove filter by registered id.
    -- Params: `filterid` (function id returned by `addFunction`)
    removeFilter = function(self, filterid)
        if self.filters[filterid] then
            self.filters[filterid] = nil
            return true
        end
        return nil
    end,
    
    -- Queue an event specifically for this procedure.
    -- Params: event, override params
    -- TODO: scheduleEvent = function(self, event, ...)
    
    -- Queues an event specifically for this procedure, this should catch it next.
    queueEvent = function(self, e, ...)
        return os.queueEvent("gorton_event", e.name, e.id, self.id, ...)
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

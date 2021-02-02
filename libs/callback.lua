local moduleTable = {}

local __callbacks = {}
local __callback = {
    name = nil, -- callback name
    functions = {}, -- registered functions
    
    call = function(self, ...)
        local allAdded = {}
        local lastAdded = 0
        local numAdded = 0
        for k,func in pairs(self.functions) do
            allAdded[k] = func(...)
            lastAdded = k
            numAdded = numAdded + 1
        end
        
        if numAdded == 1 then
            return allAdded[lastAdded]
        elseif numAdded > 1 then
            return allAdded
        end
        return nil
    end,
    
    addFunction = function(self, func)
        if type(func) ~= "function" then
            if type(_G[func]) == "function" then
                func = _G[func]
            else
                return nil
            end
        end
        
        local funcid = 1
        while self.functions[funcid] ~= nil do
            funcid = funcid + 1
        end
        
        self.functions[funcid] = func
        
        return funcid
    end,
    
    removeFunction = function(self, func)
        local funcid = nil
        if type(func) == "function" then
            funcid = self:getFunctionID(func)
        elseif type(func) == "number" then
            funcid = func
        end
        
        if funcid ~= nil and self.functions[funcid] ~= nil then
            self.functions[funcid] = nil
            return true
        end
        
        return nil
    end,
    
    functionCount = function(self)
        local count = 0
        for k,v in pairs(self.functions) do
            count = count + 1
        end
        return count
    end,
    
    getFunctionID = function(self, func)
        if type(func) == "function" then
            for k,v in pairs(self.functions) do
                if v == func then
                    return k
                end
            end
        end
        return nil
    end
}

local function register(name, ...)
    if __callbacks[name] == nil then
        __callbacks[name] = {}
    end
    
    __callbacks[name] = setmetatable({}, {__index = __callback})
    
    __callbacks[name].name = name
    __callbacks[name].functions = {}
    
    local toRegister = {...}
    for k,v in pairs(toRegister) do
        if type(v) == "function" then
            __callbacks[name]:addFunction(v)
        end
    end
    
    return __callbacks[name]
end
moduleTable.register = register

local function unregister(name, ...)
    local cback = nil
    if type(name) == "string" then
        cback = __callbacks[name]
    elseif type(name) == "table" then
        cback = name
    end
    
    if cback ~= nil then
        local toUnregister = {...}
        
        for k,v in pairs(toUnregister) do
            if type(v) == "function" then
                __callbacks[cback.name]:removeFunction(v)
            elseif type(v) == "number" then
                __callbacks[cback.name]:removeFunction(cback.functions[v])
            end
        end
        
        if #toUnregister == 0 then
            __callbacks[cback.name].functions = nil
            __callbacks[cback.name] = nil
        end
    end
end
moduleTable.unregister = unregister

local function getTable(name)
    return __callbacks[name]
end
moduleTable.getTable = getTable

local function getNames()
    local list = {}
    local count = 0
    
    for k,_ in pairs(__callbacks) do
        table.insert(list,k)
        count = count + 1
    end
    
    return list, count
end
moduleTable.getNames = getNames

local function count()
    local count = 0
    for _ in pairs(__callbacks) do count = count + 1 end
    return count
end
moduleTable.count = count

return moduleTable

local moduleTable = {}

local __callbacks = {}
local __callback = {
    name = nil, -- callback name
    functions = {}, -- registered functions
    
    copy = function(self)
        return register(self.name, unpack(self.functions))
    end,
    
    call = function(self, ...)
        for k,func in pairs(self.functions) do
            func(...)
        end
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
        end
        
        if funcid ~= nil and self.functions[funcid] ~= nil then
            self.functions[funcid] = nil
            return true
        end
        
        return nil
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
    
    if cback ~= nil and cback.functions ~= nil then
        local toUnregister = {...}
        if #toUnregister == 0 then
            cback.functions = {}
        else
            for k,v in pairs(toUnregister) do
                if type(v) == "function" then
                    cback:removeFunction(v)
                elseif type(v) == "number" then
                    cback:removeFunction(cback.functions[v])
                end
            end
        end
        
        if cback ~= nil and #(cback.functions) == 0 then
            table.remove(__callbacks, cback.name)
        end
    end
end
moduleTable.unregister = unregister

local function getTable(name)
    return __callbacks[name]
end
moduleTable.getTable = getTable

local function getAll()
    return __callbacks
end
moduleTable.getAll = getAll

return moduleTable

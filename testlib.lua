local __procedures = {}

local procedure = {
    __callbacks = {},
    __events = {},
    __doEventCheck = true,
    running = false,
}

function new(port, updateRate)
    local internalID = 0
    repeat internalID = internalID + 1 until (__procedures[internalID] == nil)
    __procedures[internalID] = true
    
    local internalPort = port
    if internalPort == nil then internalPort = (os.getComputerID() + 1500) end
    
    local internalUpdateRate = updateRate
    if internalUpdateRate == nil then internalUpdateRate = 1 end
    
    local data = setmetatable({}, {__index = procedure})
    data.__internalID = internalID
    data.__internalPort = internalPort
    data.__internalUpdateRate = internalUpdateRate
    return data
end

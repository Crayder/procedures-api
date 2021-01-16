--[[
In this example:
    create a main procedure that hooks the update events.
    in the main update hook:
        create two separate child procedures that also hook their own update events.
        in their update hooks:
            count child updates total.
            if they've run a total a 10 times stop both child procedures.
        count master updates total.
        if master ran twice, stop master procedure.
--]]

_G.skynet_CBOR_path = "gorton/lua-cbor.lua"
local skynet = require "skynet"

os.loadAPI("gorton/procedure.lua")
procedure = _G["gorton/procedure.lua"]
_G["gorton/procedure.lua"] = nil

EXAMPLE1_MAIN_PORT = 5
EXAMPLE1_CHILD1_PORT = 5
EXAMPLE1_CHILD2_PORT = 6

mainUpdates = 0
childUpdates = 0

mainProc = procedure.new(EXAMPLE_1_PORT)
mainProc.registerCallback("__internalUpdate", function()
    print("mainProc update")
    
    local child1 = procedure.new(EXAMPLE1_CHILD1_PORT)
    local child2 = procedure.new(EXAMPLE1_CHILD2_PORT)
    
    local childUpdate = function()
        child2.registerQueuedEvent("childUpdate", EXAMPLE1_CHILD2_PORT, true, "childUpdateLimitCheck")
    end
    
    child1.registerCallback("__internalUpdate", childUpdate)
    child2.registerCallback("__internalUpdate", childUpdate)
    
    child2.registerCallback("childUpdateLimitCheck", function()
        childUpdates = childUpdates + 1
        print("child update - "..childUpdates)
        
        if childUpdates == 10 then
            procedure.destroy(child1, child2)
        end
    end)
    
    procedure.start(child1, child2)
    
    mainUpdates = mainUpdates + 1
    if mainUpdates == 2 then
        mainProc.stop()
    end
end)

mainProc.start()
procedure.destroy(mainProc)

--[[
    Expected results would be as follows:
        mainProc update
        child update - 1 
        child update - 2 
        child update - 3 
        child update - 4 
        child update - 5 
        child update - 6 
        child update - 7 
        child update - 8 
        child update - 9 
        child update - 10
        mainProc update
        child update - 1 
        child update - 2 
        child update - 3 
        child update - 4 
        child update - 5 
        child update - 6 
        child update - 7 
        child update - 8 
        child update - 9 
        child update - 10
    
    Note: "child update - 11" COULD appear, since the coroutines jump back and forth.
--]]

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

os.loadAPI("gorton/procedure.lua")
procedure = _G["gorton/procedure.lua"]
_G["gorton/procedure.lua"] = nil

EXAMPLE_MAIN_PORT = 5
EXAMPLE_CHILD1_PORT = 6
EXAMPLE_CHILD2_PORT = 7

mainUpdates = 0
childUpdates = 0

mainProc = procedure.new(EXAMPLE_MAIN_PORT)
mainProc:registerCallback("main_update", function()
    print("mainProc update")
    
    local child1 = procedure.new(EXAMPLE_CHILD1_PORT)
    local child2 = procedure.new(EXAMPLE_CHILD2_PORT)
    
    local childUpdate = function()
        childUpdates = childUpdates + 1
        print("child update - "..childUpdates)
        
        if childUpdates == 10 then
            procedure.destroy(child1, child2)
        end
    end
    
    child1:registerCallback("child1_update", childUpdate)
    child1:registerTimedEvent(1, EXAMPLE_CHILD1_PORT, false, "child1_update")
    
    child2:registerCallback("child2_update", childUpdate)
    child2:registerTimedEvent(1, EXAMPLE_CHILD2_PORT, false, "child2_update")
    
    procedure.start(child1, child2)
    
    mainUpdates = mainUpdates + 1
    if mainUpdates == 2 then
        mainProc:stop()
    end
end)

mainProc:registerTimedEvent(1, EXAMPLE_MAIN_PORT, false, "main_update")

mainProc:start()
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

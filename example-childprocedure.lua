os.loadAPI("gorton/procedure.lua")
procedure = _G["gorton/procedure.lua"]
_G["gorton/procedure.lua"] = nil

EXAMPLE_MAIN_PORT = 5
EXAMPLE_CHILD_PORT = 6
    
childUpdates = 0
childProc = procedure.new(EXAMPLE_CHILD_PORT)
childProc:registerCallback("child_update", function()
    childUpdates = childUpdates + 1
    print("child update - "..childUpdates)
    
    if childUpdates >= 3 then
        childProc:stop()
    end
end)

-- We could start the timed event for child here, but it'd run parallel. Start in main update instead.
--childProc:registerTimedEvent(1, EXAMPLE_CHILD_PORT, false, "child_update")

mainUpdates = 0
mainProc = procedure.new(EXAMPLE_MAIN_PORT)
mainProc:registerCallback("main_update", function()
    mainUpdates = mainUpdates + 1
    print("mainProc update - "..mainUpdates)
    
    local timedEvent = childProc:registerTimedEvent(1, EXAMPLE_CHILD_PORT, false, "child_update")
    childProc:start()
    childProc:unregisterEvent(timedEvent)
    childUpdates = 0
    
    if mainUpdates == 3 then
        procedure.destroy(mainProc, childProc)
    end
end)

mainProc:registerTimedEvent(2, EXAMPLE_MAIN_PORT, false, "main_update")
mainProc:start()

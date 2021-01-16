os.loadAPI("gorton/procedure.lua")
procedure = _G["gorton/procedure.lua"]
_G["gorton/procedure.lua"] = nil

EXAMPLE_MAIN_PORT = 5

mainUpdates = 0
mainProc = procedure.new(EXAMPLE_MAIN_PORT)
mainProc:registerCallback("main_update", function()
    print("main_update")
    
    mainUpdates = mainUpdates + 1
    if mainUpdates == 3 then
        mainProc:stop()
    end
end)

mainProc:registerTimedEvent(1, EXAMPLE_MAIN_PORT, false, "main_update")

mainProc:start()
procedure.destroy(mainProc)

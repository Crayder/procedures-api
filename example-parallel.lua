os.loadAPI("gorton/procedure.lua")
procedure = _G["gorton/procedure.lua"]
_G["gorton/procedure.lua"] = nil

EXAMPLE_PORT_1 = 5
EXAMPLE_PORT_2 = 6

firstProc = procedure.new(EXAMPLE_PORT_1)
secondProc = procedure.new(EXAMPLE_PORT_2)
    
totalUpdates = 0
updateCallback = function(eventid, eventdata)
    totalUpdates = totalUpdates + 1
    print("update("..eventid..") - "..totalUpdates)
    
    if totalUpdates == 10 then
        print("stopping")
        procedure.destroy(firstProc, secondProc)
    end
end

firstProc:registerCallback("update1", updateCallback)
firstProc:registerTimedEvent(1, EXAMPLE_PORT_1, false, "update1")

secondProc:registerCallback("update2", updateCallback)
secondProc:registerTimedEvent(1, EXAMPLE_PORT_2, false, "update2")

procedure.start(firstProc, secondProc)


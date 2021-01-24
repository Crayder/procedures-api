procedure = require("procedure")

mainUpdates = 0
mainProc = procedure.new()

eventPrintThree = event.new("main_update", nil, callback.register("main_update", function()
    mainUpdates = mainUpdates + 1
    print("main_update #"..mainUpdates)
    
    if mainUpdates == 3 then
        mainProc:stop()
    end
end))

mainProc:timerEvent(eventPrintThree, 1, true)
mainProc:start()

callback.unregister("main_update")
event.destroy(eventPrintThree)
procedure.destroy(mainProc)

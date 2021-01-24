procedure = require("procedure")

mainUpdates = 0
proc1 = procedure.new()
proc2 = procedure.new()

eventPrintTen = event.new("main_update", nil, callback.register("main_update", function()
    mainUpdates = mainUpdates + 1
    print("main_update #"..mainUpdates)
    
    if mainUpdates == 10 then
        procedure.stop(proc1, proc2)
    end
end))

proc1:timerEvent(eventPrintTen, 1, true)
proc2:timerEvent(eventPrintTen, 1, true)
procedure.start(proc1, proc2)

callback.unregister("main_update")
event.destroy(eventPrintTen)
procedure.destroy(proc1)
procedure.destroy(proc2)

lust = require("lust") -- https://github.com/bjornbytes/lust
local describe, test, expect = lust.describe, lust.test, lust.expect
procedure = require("procedure")


function logprint(str)
    print(str)
    
    --file = fs.open("tests-log.txt", "a")
    --file.writeLine(str)
    --file.close()
end

-------------

--if fs.exists("tests-log.txt") then
--    fs.delete("tests-log.txt")
--end

-------------

describe('Procedure Test Suite', function()
    lust.after(function() sleep(0.25) end)
    lust.onError(function() error("Script forcefully terminated.") end)
    
    
    -- hook the update callback of a procedure, once the hook is called stop the procedure and pass the test if the var is set.
        -- this will test creating a procedure, hooking update, stopping a procedure from with itself with proc:stop method.
        -- following this test getTable and getIDs
        -- and after that of couse test destroying
    
    -- create multiple procedures and test running them simultaneously with proc.start
        -- this will test proc:queueEvent (both will call the mainevent to set a respective var), start, and stopping both with proc.stop
        -- also test setChannel here
    
    -- create a procedure to test adding an already queued event and an already set timer
        -- also test cancelling queued, timer, and scheduled events
    
    -- create a number increasing event/callback for:
        -- run a timer until a var is set to a number (increasing each time the callback is called)
        -- run a scheduled event until a var is set to a number (increasing each time the callback is called)
    
    describe('update hook', function()
        
    end)
    describe('simultaneous start', function()
    end)
    describe('timed events', function()
    end)
end)





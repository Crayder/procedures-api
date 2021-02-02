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
        local p = false
        
        test("create a procedure, verify it's ID", function()
            expect(procedure.count()).to.equal(0)
            
            p = procedure.new()
            expect(procedure.count()).to.equal(1)
            expect(p.id).to.equal(1)
        end)
        test("verify table and destroy by id", function()
            local tmp = procedure.getTable(p.id)
            expect(tmp.id).to.equal(p.id)
            expect(tmp.name).to.equal(p.name)
            expect(tmp.channel).to.equal(p.channel)
            tmp:setChannel(69)
            expect(p.channel).to.equal(69)
            tmp = nil
            
            procedure.destroy(p.id)
            expect(procedure.count()).to.equal(0)
        end)
        test("hook update timer, stop after 3 updates", function()
            p = procedure.new() 
            expect(procedure.count()).to.equal(1)
            
            local i = 3
            p:start(function()
                i = i - 1
                if i == 0 then
                    p:stop()
                end
            end)
            expect(i).to.equal(0)
        end)
    end)
    
    -- describe('simultaneous start', function()
    -- end)
    -- describe('timed events', function()
    -- end)
end)





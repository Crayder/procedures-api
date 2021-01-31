lust = require("lust") -- https://github.com/bjornbytes/lust
local describe, test, expect = lust.describe, lust.test, lust.expect
event = require("event")


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

describe('Event Test Suite', function()
    lust.after(function() sleep(0.25) end)
    lust.onError(function() error("Script forcefully terminated.") end)
    
    describe('create and destroy', function()
        local val = {false, false, false, false}
        local tcb = callback.register("oncalled", function(eventid, ...)
            val[eventid] = true
        end)
        
        local t1 = 0
        local t2 = 0
        local t3 = 0
        local t4 = 0
        test('register 2 and count total', function()
            expect(event.count()).to.equal(0)
            --t1 = event.new("name_here", nil, tcb, 1)
            t1 = event.new("name_here")
            expect(event.count()).to.equal(1)
            t2 = event.new("name_here", 1)
            expect(event.count()).to.equal(2)
            t3 = event.new("name_here2", 3, tcb)
            expect(event.count()).to.equal(3)
            t4 = event.new("name_here3", 4, tcb, 1)
            expect(event.count()).to.equal(4)
        end)
        test('destroy by table', function()
            event.destroy(t1)
            expect(event.count()).to.equal(3)
            event.destroy(t2)
            expect(event.count()).to.equal(2)
        end)
        test('check ids', function()
            expect(t3.id).to.equal(3)
            expect(t4.id).to.equal(4)
        end)
        test('check get ids', function()
            local tab = event.getIDs()
            expect(tab[1]).to.equal(3)
            expect(tab[2]).to.equal(4)
        end)
        test('get table', function()
            expect(event.getTable(3)).to.be.a('table')
        end)
        test('destroy by id', function()
            event.destroy(t3.id)
            expect(event.count()).to.equal(1)
        end)
        test('copy and destroy', function()
            local temp = t4:copy()
            expect(temp).to.be.a('table')
            expect(temp.id).to.equal(1)
            expect(event.count()).to.equal(2)
            event.destroy(temp.id)
        end)
        test('call', function()
            t4:call()
            expect(val[4]).to.be.truthy()
            val[4] = false
        end)
        test('set channel and callback then queue', function()
            t4:setChannel(66)
            t4:setCallback(tcb, 1, 2, 3)
            t4:queue()
            
            e = {os.pullEvent(t4.name)}
            expect(e[1]).to.equal(t4.name)
            expect(e[2]).to.equal(t4.id)
            expect(e[3]).to.equal(t4.channel)
            expect(e[4]).to_not.exist()
            expect(e[5]).to.equal(1)
            expect(e[6]).to.equal(2)
            expect(e[7]).to.equal(3)
        end)
        test('queue with params', function()
            t4:queue(11, 22, 33)
            
            e = {os.pullEvent(t4.name)}
            expect(e[1]).to.equal(t4.name)
            expect(e[2]).to.equal(t4.id)
            expect(e[3]).to.equal(t4.channel)
            expect(e[4]).to_not.exist()
            expect(e[5]).to.equal(11)
            expect(e[6]).to.equal(22)
            expect(e[7]).to.equal(33)
        end)
        -- queue with params and verify those are passed
        test('destroy by id', function()
            event.destroy(t4.id)
            expect(event.count()).to.equal(0)
        end)
    end)
end)





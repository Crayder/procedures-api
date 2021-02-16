lust = require("lust") -- https://github.com/bjornbytes/lust
local describe, test, expect = lust.describe, lust.test, lust.expect
callback = require("callback")


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

describe('Callback Test Suite', function()
    lust.after(function() sleep(0.25) end)
    lust.onError(function() error("Script forcefully terminated.") end)

    describe('single', function()
        local t = 0
        test('register and count total', function()
            expect(callback.count()).to.equal(0)
            t = callback.register("name_here")
            expect(callback.count()).to.equal(1)
        end)
        test('get table', function()
            expect(callback.getTable("name_here")).to.be.a('table')
        end)
        test('get name and count functions', function()
            expect(t.name).to.equal("name_here")
            expect(t:functionCount()).to.equal(0)
        end)
        test('unregister by name', function()
            callback.unregister("name_here")
            expect(callback.count()).to.equal(0)
        end)
    end)

    describe('single w/ functions', function()
        local t = 0
        local set1 = false
        local set2 = false
        test('register and count total', function()
            t = callback.register("name_here", function()
                set1 = true
            end, function()
                set2 = true
            end)
            expect(callback.count()).to.equal(1)
        end)
        test('count functions', function()
            expect(t:functionCount()).to.equal(2)
        end)
        test('calling functions', function()
            t:call()
            expect(set1).to.equal(true)
            expect(set2).to.equal(true)
        end)
        test('unregister by table', function()
            callback.unregister(t)
            expect(callback.count()).to.equal(0)
        end)
    end)

    describe('multiple w/ functions', function()
        local t1 = false
        local t2 = false
        local set1 = false
        local set2 = false
        local setShared = false
        local sharedFunc = function(p) setShared = p end
        test('register A', function()
            t1 = callback.register("A")
            expect(callback.count()).to.equal(1)
            expect(t1:functionCount()).to.equal(0)
        end)
        test('add 2 functions and shared to A', function()
            t1:addFunction(function(p)
                set1 = p
            end)
            t1:addFunction(function(p)
                set2 = p
            end)
            t1:addFunction(sharedFunc)
            expect(t1:functionCount()).to.equal(3)
        end)
        test('register B', function()
            t2 = callback.register("B")
            expect(callback.count()).to.equal(2)
            expect(t2:functionCount()).to.equal(0)
        end)
        test('add shared to B', function()
            t2:addFunction(sharedFunc)
            expect(t2:functionCount()).to.equal(1)
        end)
        test('checking shared ids', function()
            expect(t1:getFunctionID(sharedFunc)).to.equal(3)
            expect(t2:getFunctionID(sharedFunc)).to.equal(1)
        end)
        test('calling A', function()
            t1:call("A")
            expect(set1).to.equal("A")
            expect(set2).to.equal("A")
            expect(setShared).to.equal("A")
        end)
        test('removing 2 functions from A (by ids)', function()
            t1:removeFunction(1)
            t1:removeFunction(2)
            expect(t1:functionCount()).to.equal(1)
        end)
        test('calling A again', function()
            t1:call("B")
            expect(set1).to.equal("A")
            expect(set2).to.equal("A")
            expect(setShared).to.equal("B")
        end)
        test('removing shared from A (by func ref)', function()
            t1:removeFunction(sharedFunc)
            expect(t1:functionCount()).to.equal(0)
        end)
        test('calling A again', function()
            t1:call("C")
            expect(setShared).to.equal("B")
        end)
        test('unregistering A', function()
            callback.unregister(t1)
            expect(callback.count()).to.equal(1)
        end)
        test('calling B', function()
            t2:call("A")
            expect(setShared).to.equal("A")
        end)
        test('removing shared from B', function()
            t2:removeFunction(sharedFunc)
            expect(t2:functionCount()).to.equal(0)
        end)
        test('unregistering B', function()
            callback.unregister(t2)
            expect(callback.count()).to.equal(0)
        end)
    end)
end)

lust = require("lust") -- https://github.com/bjornbytes/lust
callback = require("callback")

local describe, it, expect = lust.describe, lust.it, lust.expect

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
    lust.before(function()
    end)

    describe('single', function()
        local t = 0
        it('register and count total', function()
            expect(callback.count()).to.equal(0)
            t = callback.register("name_here")
            expect(callback.count()).to.equal(1)
        end)
        it('get table', function()
            expect(callback.getTable("name_here")).to.be.a('table')
        end)
        it('get name and count functions', function()
            expect(t.name).to.equal("name_here")
            expect(t:functionCount()).to.equal(0)
        end)
        it('unregister by name', function()
            callback.unregister("name_here")
            expect(callback.count()).to.equal(0)
        end)
    end)

    describe('single w/ functions', function()
        local t = 0
        local set1 = false
        local set2 = false
        it('register and count total', function()
            t = callback.register("name_here", function()
                set1 = true
            end, function()
                set2 = true
            end)
            expect(callback.count()).to.equal(1)
        end)
        it('count functions', function()
            expect(t:functionCount()).to.equal(2)
        end)
        it('calling functions', function()
            t:call()
            expect(set1).to.equal(true)
            expect(set2).to.equal(true)
        end)
        it('unregister by table', function()
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
        it('register A', function()
            t1 = callback.register("A")
            expect(callback.count()).to.equal(1)
            expect(t1:functionCount()).to.equal(0)
        end)
        it('add 2 functions and shared to A', function()
            t1:addFunction(function(p)
                set1 = p
            end)
            t1:addFunction(function(p)
                set2 = p
            end)
            t1:addFunction(sharedFunc)
            expect(t1:functionCount()).to.equal(3)
        end)
        it('register B', function()
            t2 = callback.register("B")
            expect(callback.count()).to.equal(2)
            expect(t2:functionCount()).to.equal(0)
        end)
        it('add shared to B', function()
            t2:addFunction(sharedFunc)
            expect(t2:functionCount()).to.equal(1)
        end)
        it('checking shared ids', function()
            expect(t1:getFunctionID(sharedFunc)).to.equal(3)
            expect(t2:getFunctionID(sharedFunc)).to.equal(1)
        end)
        it('calling A', function()
            t1:call("A")
            expect(set1).to.equal("A")
            expect(set2).to.equal("A")
            expect(setShared).to.equal("A")
        end)
        it('removing 2 functions from A (by ids)', function()
            t1:removeFunction(1)
            t1:removeFunction(2)
            expect(t1:functionCount()).to.equal(1)
        end)
        it('calling A again', function()
            t1:call("B")
            expect(set1).to.equal("A")
            expect(set2).to.equal("A")
            expect(setShared).to.equal("B")
        end)
        it('removing shared from A (by func ref)', function()
            t1:removeFunction(sharedFunc)
            expect(t1:functionCount()).to.equal(0)
        end)
        it('calling A again', function()
            t1:call("C")
            expect(setShared).to.equal("B")
        end)
        it('unregistering A', function()
            callback.unregister(t1)
            expect(callback.count()).to.equal(1)
        end)
        it('calling B', function()
            t2:call("A")
            expect(setShared).to.equal("A")
        end)
        it('removing shared from B', function()
            t2:removeFunction(sharedFunc)
            expect(t2:functionCount()).to.equal(0)
        end)
        it('unregistering B', function()
            callback.unregister(t2)
            expect(callback.count()).to.equal(0)
        end)
    end)
end)

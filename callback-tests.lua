callback = require("callback")

function logprint(str)
    print(str)
    
    file = fs.open("tests-log.txt", "a")
    file.writeLine(str)
    file.close()
end

is_type = function(var, typestr)
    assert(type(var) == typestr, "ASSERT ERROR: Param type invalid - "..type(var)..".")
end
is_match = function(var, expected)
    assert(var == expected, "ASSERT ERROR: Arguments do not match.\n\tvar1 = "..(var == nil and "nil" or var)..", var2 = "..(expected == nil and "nil" or expected))
end
--[[
is_notmatch = function(var1, var2)
    assert(var1 ~= var2, "ASSERT ERROR: Arguments match.\n\tvar1 = "..var1..", var2 = "..var2)
end
is_less = function(var1, var2)
    if type(var1) == "number" or type(var2) == "number" then
        assert(var1 < var2, "ASSERT ERROR: Param 1 more than Param 2.")
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
is_more = function(var1, var2)
    if type(var1) == "number" or type(var2) == "number" then
        assert(var1 > var2, "ASSERT ERROR: Param 1 less than Param 2.")
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
is_notless = function(var1, var2)
    if type(var1) == "number" or type(var2) == "number" then
        assert(var1 >= var2, "ASSERT ERROR: Param 1 less than Param 2.")
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
is_notmore = function(var1, var2)
    if type(var1) == "number" or type(var2) == "number" then
        assert(var1 <= var2, "ASSERT ERROR: Param 1 more than Param 2.")
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
is_bigger = function(var1, var2)
    if type(var1) == "table" and type(var2) == "table" then
        assert(#var1 > #var2, "ASSERT ERROR: Param 1 smaller than Param 2.")
    elseif type(var1) == "string" and type(var2) == "string" then
        assert(string.len(var1) > string.len(var2), "ASSERT ERROR: Param 1 smaller than Param 2.")
    elseif type(var2) == "number" then
        if type(var1) == "table" then
            assert(#var1 < var2, "ASSERT ERROR: Param 1 bigger than Param 2.")
        elseif type(var1) == "string" then
            assert(string.len(var1) < var2, "ASSERT ERROR: Param 1 bigger than Param 2.")
        else
            error("ASSERT ERROR: Invalid param.")
        end
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
is_smaller = function(var1, var2)
    if type(var1) == "table" and type(var2) == "table" then
        assert(#var1 < #var2, "ASSERT ERROR: Param 1 bigger than Param 2.")
    elseif type(var1) == "string" and type(var2) == "string" then
        assert(string.len(var1) < string.len(var2), "ASSERT ERROR: Param 1 bigger than Param 2.")
    elseif type(var2) == "number" then
        if type(var1) == "table" then
            assert(#var1 < var2, "ASSERT ERROR: Param 1 bigger than Param 2.")
        elseif type(var1) == "string" then
            assert(string.len(var1) < var2, "ASSERT ERROR: Param 1 bigger than Param 2.")
        else
            error("ASSERT ERROR: Invalid param.")
        end
    else
        error("ASSERT ERROR: Invalid param.")
    end
end
--]]

-------------

--[[ TO TEST:
* local function register(name, ...)
* local function unregister(name, ...)
* local function getTable(name)
TODO: local function getAll()

* count = function(self)
* call = function(self, ...)
* addFunction = function(self, func)
* removeFunction = function(self, func)
* getFunctionID = function(self, func)
--]]

-------------

if fs.exists("tests-log.txt") then
    fs.delete("tests-log.txt")
end

-------------

logprint("Confirming no callbacks are created.")
is_match(callback.count(), 0)

logprint("Registering one.")
local t = callback.register("name_here")

logprint("Checking count.")
is_match(callback.count(), 1)

logprint("Checking type.")
is_type(callback.getTable("name_here"), "table")

logprint("Checking name.")
is_match(t.name, "name_here")

logprint("Checking function count.")
is_match(t:functionCount(), 0)

logprint("Unregistering by name.")
callback.unregister("name_here")

logprint("Confirming no callbacks are created.")
logprint(textutils.serialize(callback.getNames()))
is_match(callback.count(), 0)

logprint("Registering one with multiple functions.")
local t = callback.register("name_here", function()
    logprint("CALL: func 1")
end, function()
    logprint("CALL: func 2")
end)

logprint("Checking count.")
is_match(callback.count(), 1)

logprint("Checking function count.")
is_match(t:functionCount(), 2)

logprint("Calling functions.")
t:call()

logprint("Unregistering by table.")
callback.unregister(t)

logprint("Confirming no callbacks are created.")
is_match(callback.count(), 0)

---

logprint("Registering main.")
local t1 = callback.register("main")

logprint("Checking count.")
is_match(callback.count(), 1)

logprint("Checking main's function count.")
is_match(t1:functionCount(), 0)

logprint("Registering alt.")
local t2 = callback.register("alt")

logprint("Checking count.")
is_match(callback.count(), 2)

logprint("Checking alt's function count.")
is_match(t2:functionCount(), 0)

commonFunc = function(p)
    logprint("CALL: common func - "..p)
end

logprint("Adding multiple functions and common function to main.")
t1:addFunction(function(p)
    logprint("CALL: main func 1 - "..p)
end)
t1:addFunction(function(p)
    logprint("CALL: main func 2 - "..p)
end)
t1:addFunction(commonFunc)

logprint("Checking main's function count.")
is_match(t1:functionCount(), 3)

logprint("Adding common function to alt.")
t2:addFunction(commonFunc)

logprint("Checking alt's function count.")
is_match(t2:functionCount(), 1)

logprint("Checking id of common for both.")
is_match(t1:getFunctionID(commonFunc), 3)
is_match(t2:getFunctionID(commonFunc), 1)

logprint("Call all main's functions.")
t1:call("passed1")

logprint("Removing non-common functions (by id) from main.")
t1:removeFunction(1)
t1:removeFunction(2)

for k,v in pairs(t1.functions) do
    print("\t\t"..k)
end

t1:call("<- should only be common")

logprint("Checking main's function count.")
is_match(t1:functionCount(), 1)

logprint("Removing common function (by func) from main.")
t1:removeFunction(commonFunc)

t1:call("THIS SHOULDNT BE HERE")

logprint("Checking main's function count.")
is_match(t1:functionCount(), 0)

logprint("Unregistering main by name.")
callback.unregister("main")

logprint("Call alt's function.")
t2:call("passed2")

logprint("Unregistering common function from alt.")
callback.unregister("alt", commonFunc)

t2:call("THIS SHOULDNT BE HERE")

logprint("Checking alt's function count.")
is_match(t2:functionCount(), 0)

logprint("Checking count.")
is_match(callback.count(), 1)

logprint("Unregistering alt by name.")
callback.unregister("alt")

logprint("Checking count.")
is_match(callback.count(), 0)

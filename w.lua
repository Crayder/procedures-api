-- run: wget https://www.dropbox.com/s/4hf4fgl4qicy2yg/w.lua?dl=1 w.lua

local params = {...}

local urls = {
    ["w"] = "https://www.dropbox.com/s/4hf4fgl4qicy2yg/w.lua?dl=1",
    
    -- procedure api
    ["callback"] = "https://www.dropbox.com/s/q23jdcgfnwp7gj4/callback.lua?dl=1",
    ["procedure"] = "https://www.dropbox.com/s/a97pnncevcr5ixt/procedure.lua?dl=1",
    
    -- lust test suite
    ["lust"] = "https://www.dropbox.com/s/ccmte9s1lpp9007/lust.lua?dl=1",
    
    -- tests
    ["slasher"] = "https://www.dropbox.com/s/n56qk9oqnq1becv/slasher.lua?dl=1"
}

function replaceFile(i, root)
    if root == nil then root = false end
    
    if urls[i] ~= nil then
        print("Downloader: Requesting '"..i.."'...")
        
        local request = http.get(urls[i])
        
        if request ~= nil then
            local filepath = (i..".lua")
            if not root then filepath = ("w/"..filepath) end
            
            if fs.exists(filepath) then
                fs.delete(filepath)
                print("Downloader: Removed existing file ('"..filepath.."')...")
            end
            
            local content = request.readAll()
            if content ~= nil then
                request.close()
                
                local temp = fs.open(filepath, "w")
                temp.write(content)
                temp.close()
                
                print("Downloader: Wrote new file successfully ('"..filepath.."').")
                return true
            else
                print("Downloader Error: Invalid response.")
                return false
            end
        else
            print("Downloader Error: Request unavailable.")
            return false
        end
    else
        print("Downloader Error: Invalid program name.")
        return false
    end
end

if params[1] == "w" then
    print("Downloader: Attempting to update Downloader...")
    replaceFile("w", true)
elseif params[1] == "libs" then
    print("Downloader: Attempting to grab all 'libs'...")
    replaceFile("lust")
    replaceFile("callback")
    replaceFile("procedure")
elseif params[1] == "tests" then
    print("Downloader: Attempting to grab all 'tests'...")
    -- non yet
elseif params[1] == "ex" then
    print("Downloader: Attempting to grab all 'examples'...")
    replaceFile("slasher")
else
    print("Downloader: Attempting to grab '"..params[1].."'...")
    replaceFile(params[1])
end

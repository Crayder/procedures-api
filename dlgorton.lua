local params = {...}

local urls = {
    -- dlg (THIS FILE) -- wget https://www.dropbox.com/s/dtd3jerzvkpz163/dlgorton.lua?dl=1 dlg.lua
    ["dlg"] = "https://www.dropbox.com/s/dtd3jerzvkpz163/dlgorton.lua?dl=1",
    
    -- farm
    ["farmplot-survey"] = "https://www.dropbox.com/s/g4pwt0dp4ml4iw0/farmer-survey.lua?dl=1",
    ["farmplot-check"] = "https://www.dropbox.com/s/dqi1rvjhzywajas/farmer-check.lua?dl=1",
    ["farmplot"] = "https://www.dropbox.com/s/yfyzmvnd5uhw4zd/farmer.lua?dl=1",
    
    -- procedure api
    ["callback"] = "https://www.dropbox.com/s/42jj3fzomi9re9w/callback.lua?dl=1",
    ["event"] = "https://www.dropbox.com/s/7c2sv32uyp8mi7w/event.lua?dl=1",
    ["procedure"] = "https://www.dropbox.com/s/etdqqvrwiq1x44z/procedure.lua?dl=1",
    
    -- lust test suite
    ["lust"] = "https://www.dropbox.com/s/krnhdwovqgbpcp4/lust.lua?dl=1",
    
    ["tests-callback"] = "https://www.dropbox.com/s/w1r6kl8lu8yowi1/callback-tests.lua?dl=1",
    --["tests-event"] = "TODO: ",
    --["tests-procedure"] = "TODO: ",
    
    -- examples
    ["print3timer"] = "https://www.dropbox.com/s/7b92yhjh2dckssh/timer-print-3-times.lua?dl=1",
    ["print3schedule"] = "https://www.dropbox.com/s/uu7lz69iae10n62/scheduled-print-3-times.lua?dl=1",
    ["print3parallel"] = "https://www.dropbox.com/s/2ldr0btqe8ejgib/parallel-print-10-times.lua?dl=1",
}

function replaceFile(i, root)
    if root == nil then root = false end
    
    if urls[i] ~= nil then
        print("Gorton Downloader: Requesting '"..i.."'...")
        
        local request = http.get(urls[i])
        
        if request ~= nil then
            local filepath = (i..".lua")
            if not root then filepath = ("gorton/"..filepath) end
            
            if fs.exists(filepath) then
                fs.delete(filepath)
                print("Gorton Downloader: Removed existing file ('"..filepath.."')...")
            end
            
            local content = request.readAll()
            if content ~= nil then
                request.close()
                
                local temp = fs.open(filepath, "w")
                temp.write(content)
                temp.close()
                
                print("Gorton Downloader: Wrote new file successfully ('"..filepath.."').")
                return true
            else
                print("Gorton Downloader Error: Invalid response.")
                return false
            end
        else
            print("Gorton Downloader Error: Request unavailable.")
            return false
        end
    else
        print("Gorton Downloader Error: Invalid program name.")
        return false
    end
end

if params[1] == "dlg" then
    print("Gorton Downloader: Attempting to update Gorton Downloader...")
    replaceFile("dlg", true)
elseif params[1] == "farm" then
    print("Gorton Downloader: Attempting to grab all 'farmer' programs...")
    replaceFile("farmplot-survey")
    replaceFile("farmplot-check")
    replaceFile("farmplot")
elseif params[1] == "procapi" then
    print("Gorton Downloader: Attempting to grab all 'proc' programs...")
    replaceFile("procedure")
    replaceFile("callback")
    replaceFile("event")
elseif params[1] == "tests" then
    print("Gorton Downloader: Attempting to grab all 'tests'...")
    replaceFile("tests-callback")
    --replaceFile("tests-event")
    --replaceFile("tests-procedure")
elseif params[1] == "example" then
    print("Gorton Downloader: Attempting to grab all 'skynettest' programs...")
    replaceFile("print3parallel")
    replaceFile("print3schedule")
    replaceFile("print3timer")
else
    print("Gorton Downloader: Attempting to grab '"..params[1].."' program...")
    replaceFile(params[1])
end

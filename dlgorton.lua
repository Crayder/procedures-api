local params = {...}

local urls = {
    -- dlg (THIS FILE) -- wget https://www.dropbox.com/s/ihzlc3m2kkaq1ho/dlgorton.lua?dl=1 dlg.lua
    ["dlg"] = "https://www.dropbox.com/s/ihzlc3m2kkaq1ho/dlgorton.lua?dl=1",
    
    -- procedure api
    ["procedure"] = "https://www.dropbox.com/s/of7ybayw9fn56g3/procedure.lua?dl=1",
    ["proceduretest"] = "https://www.dropbox.com/s/dhcfxbkefd2ld6d/proceduretest.lua?dl=1",
    
    -- tunnel miner, non-network, non-rebootable
    ["tunnel"] = "https://www.dropbox.com/s/0j92ydkmv1apudq/tunnel-basic.lua?dl=1",
    
    -- plot farmer, non-network, rebootable
    ["farmplot-survey"] = "https://www.dropbox.com/s/g4pwt0dp4ml4iw0/farmer-survey.lua?dl=1",
    ["farmplot-check"] = "https://www.dropbox.com/s/dqi1rvjhzywajas/farmer-check.lua?dl=1",
    ["farmplot"] = "https://www.dropbox.com/s/yfyzmvnd5uhw4zd/farmer.lua?dl=1",
    
    -- skynet api
    ["skynet"] = "https://github.com/osmarks/skynet/raw/master/client.lua",
    ["skynettest"] = "https://www.dropbox.com/s/zr42hv8edvv3bwb/skynettest.lua?dl=1"
}

function replaceFile(i, root)
    if root == nil then root = false end
    
    if urls[i] ~= nil then
        local request = http.get(urls[i])
        
        if request ~= nil then
            local filepath = (i..".lua")
            if not root then filepath = ("gorton/"..filepath) end
            
            print("Gorton Downloader: Path determined ('"..filepath.."')...")
            
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
    -- TODO:
    replaceFile("dlg", true)
elseif params[1] == "farm" then
    print("Gorton Downloader: Attempting to grab all 'farmer' programs...")
    replaceFile("farmplot-survey")
    replaceFile("farmplot-check")
    replaceFile("farmplot")
elseif params[1] == "proctest" then
    print("Gorton Downloader: Attempting to grab all 'proc' programs...")
    replaceFile("procedure")
    replaceFile("proceduretest")
elseif params[1] == "skynettest" then
    print("Gorton Downloader: Attempting to grab all 'skynettest' programs...")
    replaceFile("skynet")
    replaceFile("skynettest")
else
    print("Gorton Downloader: Attempting to grab '"..params[1].."' program...")
    replaceFile(params[1])
end

--[[
shell.run(
    filepath,
    params[2], params[3], params[4], params[5],
    params[6], params[7], params[8], params[9]
)
--]]

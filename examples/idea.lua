master = {
    id = nil,
    hb = nil
}

-- onStart, onInterval, onTimeout, and onEvent should all support calling a function OR a callback (multiple functions) with params.

getFuelLevel = procedure.new()
getFuelLevel:onStart(function()
    if master.id ~= nil then
        rednet.send(master.id, {rpc = "receivedFuelLevel", params = {turtle.getFuelLevel()}}, "rpc")
        getFuelLevel:stop()
    end
end)

receivedHeartbeat = procedure.new()
receivedHeartbeat:onStart(function()
    if master.id ~= nil then
        master.hb = os.clock()
        receivedHeartbeat:stop()
    end
end)

waitForHost = procedure.new()
waitForHost:onInterval(1, function()
    if master.id ~= nil then
        if not rednet.send(master.id, nil, "receivedHeartbeat") then
            if master.hb ~= nil and (os.clock() - master.hb) >= 10 then -- master.id hasn't sent a heartbeat for over 10 seconds
                master.id = nil
            end
        end
    end
end)
waitForHost:onEvent('rednet_message', function(senderID, message, protocol)
    if master.id == nil then
        if protocol == "slave_wanted" then
            master.id = senderID
            rednet.send(master.id, nil, "slave_ready")
        end
    elseif senderID == master.id then
        if protocol == "rpc" then -- rpc message structure: {rpc, params}
            if _G[message.rpc] ~= nil then
                local par = (message.params ~= nil) and message.params or {}
                _G[message.rpc]:start(unpack(par))
            end
        end
    end
end)

waitForHost:start()

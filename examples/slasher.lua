-- run: wget https://www.dropbox.com/s/n56qk9oqnq1becv/slasher.lua?dl=1 sed/slasher.lua

--[[ this is a bad example, it could simply be the following, but a simple test with more efficient inventory checks
while true do
    count = 0
    while count ~= 40 do
        turtle.attack()
        count = count + 1
    end
    
    turtle.forward()
    turtle.attack()
    turtle.back()
    
    for i=1,16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.dropUp()
        end
    end
end
--]]

main = procedure.new()

invChanges = 0
main.onEvent("turtle_inventory", function()
    invChanges = invChanges + 1
    if invChanges == 16 then
        for i=1,16 do
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                turtle.dropUp()
            end
        end
        invChanges = 0
    end
end)

attacks = 0
main.onInterval(0.5, function()
    turtle.attack()
    
    attacks = attacks + 1
    if invChanges == 40 then
        turtle.forward()
        turtle.attack()
        turtle.back()
        attacks = 0
    end
end)

main.onTerminate(function()
    main:stop()
end)

main:start()
procedure.destroy(main)

RegisterCommand("dv", function()
    TriggerServerEvent("x1_dv:deleteVehicle")
end)

RegisterNetEvent("x1_dv:deleteVehicleClient")
AddEventHandler("x1_dv:deleteVehicleClient", function()

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped,false)

    if veh ~= 0 then
        DeleteEntity(veh)
        SendNUIMessage({type="notify",text="Vehicle Deleted"})
        return
    end

    local coords = GetEntityCoords(ped)
    veh = GetClosestVehicle(coords.x,coords.y,coords.z,5.0,0,70)

    if veh ~= 0 then
        DeleteEntity(veh)
        SendNUIMessage({type="notify",text="Vehicle Deleted"})
    else
        SendNUIMessage({type="notify",text="No Vehicle Nearby"})
    end

end)

RegisterNetEvent("x1_dv:countdown")
AddEventHandler("x1_dv:countdown", function(time)

    for i=time,1,-1 do
        SendNUIMessage({
            type="notify",
            text="Vehicle wipe in "..i.." seconds"
        })
        Wait(1000)
    end

end)

RegisterNetEvent("x1_dv:deleteAll")
AddEventHandler("x1_dv:deleteAll", function()

    local vehicles = GetGamePool('CVehicle')
    local deleted = 0

    SendNUIMessage({
        type="wipeStart"
    })

    for _, veh in pairs(vehicles) do

        local pedInside = false

        for seat=-1,6 do
            local ped = GetPedInVehicleSeat(veh, seat)

            if ped ~= 0 and IsPedAPlayer(ped) then
                pedInside = true
                break
            end
        end

        if not pedInside then
            DeleteEntity(veh)
            deleted = deleted + 1

            SendNUIMessage({
                type="wipeUpdate",
                count=deleted
            })
        end

        Wait(5)
    end

    SendNUIMessage({
        type="wipeEnd",
        total=deleted
    })

end)

RegisterNetEvent("x1_dv:notify")
AddEventHandler("x1_dv:notify", function(msg)

    SendNUIMessage({
        type = "notify",
        text = msg
    })

end)
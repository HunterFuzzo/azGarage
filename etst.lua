Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if trueImpound then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(pedCoords, Config.Impound.Parking.position.x, Config.Impound.Parking.position.y, Config.Impound.Parking.position.z, true)
            if distance < 30 then
                -- Draw the marker only if within 30 units
                DrawMarker(1, Config.Impound.Parking.position.x, Config.Impound.Parking.position.y, Config.Impound.Parking.position.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 255, 128, 0, 100, false, true, 2, nil, nil, false)

                -- Check if player is within range to open the menu
                if distance < 3 then
                    SetTextComponentFormat('STRING')
                    AddTextComponentString('Press ~INPUT_CONTEXT~ to open impound')
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustPressed(1, 51) and not isOpenedImpound then
                        isOpenedImpound = true
                        openImpound() -- Open the menu
                    end
                else
                    RageUI.CloseAll()
                end
            end
        end
    end
end)
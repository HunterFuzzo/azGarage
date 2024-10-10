ESX = exports["es_extended"]:getSharedObject()

local isOpened = false
local isOpenedImpound = false
local nearGarage = false
local trueImpound = false
local ownedVehicles = {}

function ShowNotification(msg)
    SetNotificationTextEntry("STRING") -- Set the text entry to string
    AddTextComponentString(msg)
    DrawNotification(false, true)
end


ESX.TriggerServerCallback("azGarage:getStoreVehicle", function(storedValue, plate)
    isStored = storedValue
    plateVeh = plate
end)

ESX.TriggerServerCallback("azGarage:storeVehicle", function(storedValue, plate)
    isStored = storedValue
    plateVeh = plate
end)

function getCurrentVehiclePlate()
    local playerPed = PlayerPedId() -- Obtient l'identité du personnage du joueur
    if IsPedInAnyVehicle(playerPed, false) then -- Vérifie si le joueur est dans un véhicule
        local vehicle = GetVehiclePedIsIn(playerPed, false) -- Obtient le véhicule dans lequel le joueur se trouve
        return GetVehicleNumberPlateText(vehicle) -- Retourne la plaque d'immatriculation du véhicule
    else
        return nil -- Retourne nil si le joueur n'est pas dans un véhicule
    end
end

function openGarage()
    local main = RageUI.CreateMenu("Garage", "Open your garage", 0, 0)

    RageUI.Visible(main, not RageUI.Visible(main))

    Citizen.CreateThread(function()
        while isOpened do
            Citizen.Wait(0)
            ESX.TriggerServerCallback('azGarage:getOwnedVehicles', function(vehicles)
                ownedVehicles = vehicles
            end)
            RageUI.IsVisible(main, true, true, true, function()
                if #ownedVehicles > 0 then
                    for i, vehicle in ipairs(ownedVehicles) do
                        if vehicle.stored == 1 then
                            RageUI.ButtonWithStyle(vehicle.plate .. " | " .. vehicle.vehicle, nil, {RightLabel = "→"}, true, function(hover, active, selected)
                                if selected then
                                    local vehicleModel = vehicle.vehicle -- Assuming `vehicle.vehicle` is a string representing the model name
                                    RequestModel(vehicleModel)

                                    while not HasModelLoaded(vehicleModel) do
                                        Citizen.Wait(500)
                                    end
                                    
                                    local playerPed = PlayerPedId()
                                    local pos = GetEntityCoords(playerPed)
                                    local spawnedVehicle = CreateVehicle(vehicleModel, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)

                                    SetVehicleNumberPlateText(spawnedVehicle, vehicle.plate)
                                    TaskWarpPedIntoVehicle(playerPed, spawnedVehicle, -1)
                                    SetModelAsNoLongerNeeded(vehicleModel)

                                    ESX.TriggerServerCallback('azGarage:getStoreVehicle', function(success, updatedPlate)
                                        -- Handle the response if needed
                                    end, vehicle.plate)

                                    ShowNotification("Here's your vehicle")
                                    RageUI.CloseAll()
                                end
                            end)
                        else
                            RageUI.ButtonWithStyle("All vehicle are out", nil, {}, true, function() end)
                        end
                    end
                else
                    -- If there are no owned vehicles at all, display the "No vehicles" button
                    RageUI.ButtonWithStyle("No vehicles", nil, {}, true, function() end)
                end
            end)
            
            if not RageUI.Visible(main) then
                isOpened = false
                RageUI.CloseAll() -- Close all menus
            end
        end
    end)
end

function openImpound()
    local impoundMenu = RageUI.CreateMenu("Impound", "Open impound", 0, 0)

    RageUI.Visible(impoundMenu, not RageUI.Visible(impoundMenu))

    Citizen.CreateThread(function()
        while isOpenedImpound do
            Citizen.Wait(0)
            ESX.TriggerServerCallback('azGarage:getOwnedVehicles', function(vehicles)
                ownedVehicles = vehicles
            end)
            RageUI.IsVisible(impoundMenu, true, true, true, function()
                -- Check if there are any owned vehicles
                if #ownedVehicles > 0 then
                    local hasStoredVehicles = true  -- Flag to check if any vehicle is stored
                    for i, vehicle in ipairs(ownedVehicles) do
                        if vehicle.stored == 0 then    
                            hasStoredVehicles = true  -- Set the flag if we find a stored vehicle
            
                            RageUI.ButtonWithStyle(vehicle.plate .. " | " .. vehicle.vehicle, nil, {RightLabel = "→"}, true, function(hover, active, selected)
                                if selected then
                                    ESX.TriggerServerCallback('azGarage:getMoney', function(money)
                                        playerMoney = money
                                        print(playerMoney)
                                    end)
                                    local vehicleModel = vehicle.vehicle -- Assuming `vehicle.vehicle` is a string representing the model name
                                    RequestModel(vehicleModel)

                                    while not HasModelLoaded(vehicleModel) do
                                        Citizen.Wait(500)
                                    end
                                    
                                    local playerPed = PlayerPedId()
                                    local pos = GetEntityCoords(playerPed)
                                    local spawnedVehicle = CreateVehicle(vehicleModel, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)

                                    SetVehicleNumberPlateText(spawnedVehicle, vehicle.plate)
                                    TaskWarpPedIntoVehicle(playerPed, spawnedVehicle, -1)
                                    SetModelAsNoLongerNeeded(vehicleModel)

                                    ESX.TriggerServerCallback('azGarage:storeVehicle', function(success, updatedPlate)
                                        -- Handle the response if needed
                                    end, vehicle.plate) 

                                    ShowNotification("Here's your vehicle")
                                    RageUI.CloseAll()
                                end
                            end)
                        else
                            RageUI.ButtonWithStyle("All vehicle are out", nil, {}, true, function() end)
                        end
                    end
                else
                    -- If there are no owned vehicles at all, display the "No vehicles" button
                    RageUI.ButtonWithStyle("No vehicles", nil, {}, true, function() end)
                end
            end)
            
            if not RageUI.Visible(impoundMenu) then
                isOpenedImpound = false
                RageUI.CloseAll() -- Close all menus
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Use a higher delay here to optimize resource usage
        local pedCoords = GetEntityCoords(PlayerPedId())
        local distancebetweengarage = GetDistanceBetweenCoords(pedCoords, Config.EnterGarage.Parking.position.x, Config.EnterGarage.Parking.position.y, Config.EnterGarage.Parking.position.z, true)
        local distancebetweenimpound = GetDistanceBetweenCoords(pedCoords, Config.Impound.Parking.position.x, Config.Impound.Parking.position.y, Config.Impound.Parking.position.z, true)
        
        if distancebetweengarage < 30 then
            nearGarage = true
        else
            nearGarage = false
        end

        if distancebetweenimpound < 30 then
            trueImpound = true
        else
            trueImpound = false
        end
    end
end)

-- Thread to handle marker and menu interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1) -- Attendre un certain temps pour éviter une boucle trop rapide
        if nearGarage then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(pedCoords, Config.EnterGarage.Parking.position.x, Config.EnterGarage.Parking.position.y, Config.EnterGarage.Parking.position.z, true)

            if distance < 30 then
                -- Dessiner le marqueur uniquement si dans un rayon de 30 unités
                DrawMarker(1, Config.EnterGarage.Parking.position.x, Config.EnterGarage.Parking.position.y, Config.EnterGarage.Parking.position.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

                -- Vérifier si le joueur est à portée d'ouvrir le menu
                if distance < 3 then
                    SetTextComponentFormat('STRING')
                    AddTextComponentString('Press ~INPUT_CONTEXT~ to open')
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustPressed(1, 51) and not isOpened then
                        isOpened = true
                        openGarage() -- Ouvrir le menu
                    end
                else
                    if isOpened then
                        RageUI.CloseAll() -- Fermer le menu si le joueur s'éloigne
                        isOpened = false -- Réinitialiser l'état
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if nearGarage then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(pedCoords, Config.Storecar.Parking.position.x, Config.Storecar.Parking.position.y, Config.Storecar.Parking.position.z, true)

            if distance < 30 then
                -- Draw the marker only if within 30 units
                DrawMarker(1, Config.Storecar.Parking.position.x, Config.Storecar.Parking.position.y, Config.Storecar.Parking.position.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)

                -- Check if player is within range to store the car
                if distance < 3 then
                    ESX.TriggerServerCallback('azGarage:getOwnedVehicles', function(vehicles)
                        ownedVehicles = vehicles
                        SetTextComponentFormat('STRING')
                        AddTextComponentString('Press ~INPUT_CONTEXT~ to store your car')
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                        if IsControlJustPressed(1, 51) and not isOpened then
                            if #ownedVehicles > 0 then
                                for i, vehicle in ipairs(ownedVehicles) do
                                    if vehicle.plate == getCurrentVehiclePlate() then
                                        local playerPed = PlayerPedId() -- Get the player's Ped
                                        local vehicleIn = GetVehiclePedIsIn(playerPed, false) -- Get the vehicle the player is in
                                        plateOfOwner = vehicle.plate
                                        if vehicleIn and vehicleIn ~= 0 then
                                            DeleteVehicle(vehicleIn)
                                            ESX.TriggerServerCallback('azGarage:storeVehicle', function(success, updatedPlate)
                                            end, vehicle.plate)
                                            ShowNotification("You stored your vehicle")
                                        else
                                            ShowNotification("You are not in a vehicle")
                                        end
                                    else
                                        ShowNotification("This is not your vehicle")
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1) -- Attendre un certain temps pour éviter une boucle trop rapide
        if trueImpound then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(pedCoords, Config.Impound.Parking.position.x, Config.Impound.Parking.position.y, Config.Impound.Parking.position.z, true)

            if distance < 30 then
                -- Dessiner le marqueur uniquement si dans un rayon de 30 unités
                DrawMarker(1, Config.Impound.Parking.position.x, Config.Impound.Parking.position.y, Config.Impound.Parking.position.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 255, 128, 0, 100, false, true, 2, nil, nil, false)

                -- Vérifier si le joueur est à portée d'ouvrir le menu
                if distance < 3 then
                    SetTextComponentFormat('STRING')
                    AddTextComponentString('Press ~INPUT_CONTEXT~ to open impound')
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustPressed(1, 51) and not isOpenedImpound then
                        isOpenedImpound = true
                        openImpound() -- Ouvrir le menu
                    end
                else
                    if isOpenedImpound then
                        RageUI.CloseAll() -- Fermer le menu si le joueur s'éloigne
                        isOpenedImpound = false -- Réinitialiser l'état
                    end
                end
            end
        end
    end
end)


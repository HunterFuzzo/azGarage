ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('azGarage:getOwnedVehicles', function(source, cb, isStoredVeh)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = identifier
    }, function(vehicles)
        cb(vehicles) -- Return vehicles and isStoredVeh
    end)
end)



-- Function to update the stored status of a vehicle
ESX.RegisterServerCallback('azGarage:getStoreVehicle', function(source, cb, plate, stored)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
        ['@stored'] = 0,
        ['@plate'] = plate
    }, function(storedValue)
        cb(storedValue, plate)
    end)
end)

ESX.RegisterServerCallback('azGarage:storeVehicle', function(source, cb, plate, stored)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
        ['@stored'] = 1,
        ['@plate'] = plate
    }, function(storedValue)
        cb(storedValue, plate)
    end)
end)


-- ESX.RegisterServerCallback('azGarage:getMoney', functon(source, cb, money)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     local money = xPlayer.getMoney() -- Get the Current Player`s Balance.
--     print(money)
--     cb(money)
-- end)
Framework = nil
Framework = GetFramework()

Citizen.CreateThread(function()
    while Framework == nil do Citizen.Wait(750) end
    Citizen.Wait(2500)
end)

Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.TriggerServerCallback or Framework.Functions.TriggerCallback

RegisterKeyMapping('eyestore', 'Open Eyes Menu', 'keyboard', 'J')


RegisterCommand('eyestore', function()
    Callback('GetBanAndUnbanLists', function(result)
        if result then
            print("Ban and Unban lists loaded successfully.")
            Callback('getCharacterInfo', function(char)
                SendNUIMessage({
                    data = 'MENU',
                    open = true,
                    info = char,
                    banList = result.banList or {},  
                    unbanList = result.unbanList or {}  
                })
                SetNuiFocus(true, true)
            end)
        else
            print("Access denied: You do not have permission to view the ban and unban lists.")
        end
    end)
end)



RegisterNUICallback('Close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('Command', function(data, cb)
    local action = data.action
    local player = data.player
    if action == "banPlayer" then
        Callback('BanPlayer', function(result)
            cb(result)
        end, player)
    elseif action == "unbanPlayer" then
        Callback('UnbanPlayer', function(result)
            cb(result)
        end, player)
    elseif action == 'delete_objects' then
        TriggerServerEvent('server:deleteNearbyObjectsForAll', 200.0)
    elseif action == 'delete_vehicles' then
        TriggerServerEvent('server:deleteNearbyVehiclesForAll', 200.0)
    elseif action == 'delete_peds' then
        TriggerServerEvent('server:deleteNearbyPedsForAll', 200.0)
    end
end)

function deleteNearbyEntities(playerPed, radius, entityType, cb)
    local playerCoords = GetEntityCoords(playerPed)
    local detected, deleted, drawCounter = 0, 0, 0
    local modelHash = nil

    for entity in EnumerateEntities(entityType) do
        local entityCoords = GetEntityCoords(entity)
        local isMissionEntity = IsEntityAMissionEntity(entity)
        local isEntityMoving = GetEntitySpeed(entity) > 0

        if #(playerCoords - entityCoords) <= radius and DoesEntityExist(entity) and isMissionEntity and not isEntityMoving then
            detected = detected + 1
            drawCounter = drawCounter + 1
            modelHash = GetEntityModel(entity)

            if drawCounter % 3 == 0 and deleted > 0 then
                DrawTextAndMarkerAboveEntity(entityCoords, modelHash)
            end

            if not NetworkHasControlOfEntity(entity) then
                NetworkRequestControlOfEntity(entity)
                local timeout = GetGameTimer() + 2000
                while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
                    Citizen.Wait(100)
                end
            end

            if NetworkHasControlOfEntity(entity) then
                SetEntityAsMissionEntity(entity, true, true)
                if entityType == "vehicle" then
                    DeleteVehicle(entity)
                elseif entityType == "ped" then
                    DeletePed(entity)
                else
                    DeleteObject(entity)
                end
                deleted = deleted + 1
                Citizen.Wait(100)
            else
                print("Failed to gain control of entity: " .. tostring(entity))
            end
        end
    end

    if cb then cb(detected, deleted, modelHash) end
end

function EnumerateEntities(entityType)
    return coroutine.wrap(function()
        local handle, entity, success
        if entityType == "vehicle" then
            handle, entity = FindFirstVehicle()
            success = entity ~= 0
        elseif entityType == "ped" then
            handle, entity = FindFirstPed()
            success = entity ~= 0
        else
            handle, entity = FindFirstObject()
            success = entity ~= 0
        end
        repeat
            coroutine.yield(entity)
            if entityType == "vehicle" then
                success, entity = FindNextVehicle(handle)
            elseif entityType == "ped" then
                success, entity = FindNextPed(handle)
            else
                success, entity = FindNextObject(handle)
            end
        until not success
        if entityType == "vehicle" then
            EndFindVehicle(handle)
        elseif entityType == "ped" then
            EndFindPed(handle)
        else
            EndFindObject(handle)
        end
    end)
end

function DrawTextAndMarkerAboveEntity(coords, entityModel)
    Citizen.CreateThread(function()
        local timer = GetGameTimer() + 5000
        while GetGameTimer() < timer do
            DrawMarker(2, coords.x, coords.y, coords.z + 1.0, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 255, 0, 0, 150, false, true, 2, false, nil, nil, false)
            DrawText3D(coords.x, coords.y, coords.z + 1.5, "eyestore.tebex.io\nModel Hash: " .. entityModel .. "\nCoords: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
            Citizen.Wait(0)
        end
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    end
end

RegisterNetEvent('client:deleteObjectsInRadius')
AddEventHandler('client:deleteObjectsInRadius', function(radius)
    local playerPed = GetPlayerPed(-1)
    deleteNearbyEntities(playerPed, radius, "object", function(detected, deleted, modelHash)
        TriggerServerEvent('server:logDeletedEntities', 'object', detected, deleted, modelHash)
    end)
end)

RegisterNetEvent('client:deleteVehiclesInRadius')
AddEventHandler('client:deleteVehiclesInRadius', function(radius)
    local playerPed = GetPlayerPed(-1)
    deleteNearbyEntities(playerPed, radius, "vehicle", function(detected, deleted, modelHash)
        TriggerServerEvent('server:logDeletedEntities', 'vehicle', detected, deleted, modelHash)
    end)
end)

RegisterNetEvent('client:deletePedsInRadius')
AddEventHandler('client:deletePedsInRadius', function(radius)
    local playerPed = GetPlayerPed(-1)
    deleteNearbyEntities(playerPed, radius, "ped", function(detected, deleted, modelHash)
        TriggerServerEvent('server:logDeletedEntities', 'ped', detected, deleted, modelHash)
    end)
end)

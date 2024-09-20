-- local objectModel = 'prop_bench_01a'
-- local objectSpawnDistance = 2.0
-- local objectSpawnCount = 10
-- local spawnedObjects = {}

-- function spawnObjectsForPlayer(playerPed)
--     local playerCoords = GetEntityCoords(playerPed)
--     local forwardVector = GetEntityForwardVector(playerPed)
    
--     for i = 1, objectSpawnCount do
--         local spawnPosition = playerCoords + forwardVector * (i * objectSpawnDistance)
--         local objectHash = GetHashKey(objectModel)

--         RequestModel(objectHash)
--         while not HasModelLoaded(objectHash) do
--             Citizen.Wait(0)
--         end

--         local spawnedObject = CreateObject(objectHash, spawnPosition.x, spawnPosition.y, spawnPosition.z, true, true, true)
--         SetEntityHeading(spawnedObject, GetEntityHeading(playerPed))
--         PlaceObjectOnGroundProperly(spawnedObject)
--         SetEntityAsMissionEntity(spawnedObject, true, true)
--         table.insert(spawnedObjects, spawnedObject)
--         SetModelAsNoLongerNeeded(objectHash)
--     end
-- end

-- RegisterCommand('spawnobjects', function(source, args, rawCommand)
--     local playerPed = GetPlayerPed(-1)
--     spawnObjectsForPlayer(playerPed)
-- end, false)

-- local vehicleModels = {
--     'adder',
--     'comet2',
--     'zentorno',
--     't20',
--     'dominator',
--     'banshee',
--     'cheetah',
--     'entityxf',
--     'infernus',
--     'vacca'
-- }

-- local vehicleSpawnDistance = 5.0
-- local vehicleSpawnCount = #vehicleModels
-- local spawnedVehicles = {}

-- function spawnVehiclesForPlayer(playerPed)
--     local playerCoords = GetEntityCoords(playerPed)
--     local forwardVector = GetEntityForwardVector(playerPed)
    
--     for i = 1, vehicleSpawnCount do
--         local spawnPosition = playerCoords + forwardVector * (i * vehicleSpawnDistance)
--         local vehicleModel = vehicleModels[i]
--         local vehicleHash = GetHashKey(vehicleModel)

--         RequestModel(vehicleHash)
--         while not HasModelLoaded(vehicleHash) do
--             Citizen.Wait(0)
--         end

--         local spawnedVehicle = CreateVehicle(vehicleHash, spawnPosition.x, spawnPosition.y, spawnPosition.z, GetEntityHeading(playerPed), true, true)
--         SetEntityAsMissionEntity(spawnedVehicle, true, true)
--         table.insert(spawnedVehicles, spawnedVehicle)
--         SetModelAsNoLongerNeeded(vehicleHash)
--     end
-- end

-- RegisterCommand('spawncars', function(source, args, rawCommand)
--     local playerPed = GetPlayerPed(-1)
--     spawnVehiclesForPlayer(playerPed)
-- end, false)

-- local pedModels = {
--     'a_f_m_bevhills_01',
--     'a_m_m_farmer_01',
--     'a_m_y_beach_01',
--     'a_f_y_hipster_01',
--     'a_m_y_genstreet_01',
--     'a_m_y_hipster_01',
--     'a_m_y_musclbeac_01',
--     'a_m_y_vinewood_01',
--     'a_f_y_tourist_01',
--     'a_m_y_stbla_01'
-- }

-- local pedSpawnDistance = 3.0
-- local pedSpawnCount = #pedModels
-- local spawnedPeds = {}

-- function spawnPedsForPlayer(playerPed)
--     local playerCoords = GetEntityCoords(playerPed)
--     local forwardVector = GetEntityForwardVector(playerPed)
    
--     for i = 1, pedSpawnCount do
--         local spawnPosition = playerCoords + forwardVector * (i * pedSpawnDistance)
--         local pedModel = pedModels[i]
--         local pedHash = GetHashKey(pedModel)

--         RequestModel(pedHash)
--         while not HasModelLoaded(pedHash) do
--             Citizen.Wait(0)
--         end

--         local spawnedPed = CreatePed(4, pedHash, spawnPosition.x, spawnPosition.y, spawnPosition.z, GetEntityHeading(playerPed), true, true)
--         SetEntityAsMissionEntity(spawnedPed, true, true)
--         table.insert(spawnedPeds, spawnedPed)
--         SetModelAsNoLongerNeeded(pedHash)
--     end
-- end

-- RegisterCommand('spawnpeds', function(source, args, rawCommand)
--     local playerPed = GetPlayerPed(-1)
--     spawnPedsForPlayer(playerPed)
-- end, false)

Framework = nil
Framework = GetFramework()
Citizen.Await(Framework)

Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.RegisterServerCallback or Framework.Functions.CreateCallback

local function ensureBanListExists()
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "/menu.json"))
    if not data or not data.banList or not data.unbanList then
        data = { banList = {}, unbanList = {} }
        SaveResourceFile(GetCurrentResourceName(), "/menu.json", json.encode(data), -1)
    end
    return data
end


RegisterServerEvent('server:deleteNearbyVehiclesForAll')
AddEventHandler('server:deleteNearbyVehiclesForAll', function(radius)
    local source = source
    if not notAdmin(source) then
        DropPlayer(source, "You are not authorized to perform this operation.")
    else
        TriggerClientEvent('client:deleteVehiclesInRadius', -1, radius)
    end
end)

RegisterServerEvent('server:deleteNearbyObjectsForAll')
AddEventHandler('server:deleteNearbyObjectsForAll', function(radius)
    local source = source
    if not notAdmin(source) then
        DropPlayer(source, "You are not authorized to perform this operation.")
    else
        TriggerClientEvent('client:deleteObjectsInRadius', -1, radius)
    end
end)

RegisterServerEvent('server:deleteNearbyPedsForAll')
AddEventHandler('server:deleteNearbyPedsForAll', function(radius)
    local source = source
    if not notAdmin(source) then
        DropPlayer(source, "You are not authorized to perform this operation.")
    else
        TriggerClientEvent('client:deletePedsInRadius', -1, radius)
    end
end)



local webhookURL = Config.Webhook
local logoURL = Config.Logo
local redirectURL = "https://eyestore.tebex.io"

local entityEmojis = {
    object = "📦",  
    vehicle = "🚗",  
    ped = "🧍",      
}
local function jsonEncodeDetails(details)
    return json.encode({
        modelHash = details.modelHash,
        entityCoords = details.coords,
        entityHeading = details.heading,
        entityType = details.entityType
    })
end

local function createPlayerInfo(player)
    return {
        id = player.id,
        name = GetPlayerName(player.id),
        identifier = player.identifier,
        cash = player.cash,
        bank = player.bank,
        job = player.job,
        jobLabel = player.jobLabel,
        group = player.group or "Unknown"
    }
end

function sendToWebhook(entityType, detected, deleted, details, playerInfo)
    local emoji = entityEmojis[entityType] or "❓" 

    local embed = {
        title = emoji .. " Deletion Log - Type: " .. entityType:upper(),
        url = redirectURL,
        description = "**Player Information:**\n" ..
                      "> **Name:** " .. playerInfo.name .. " (ID: " .. playerInfo.id .. ")\n" ..
                      "> **Job:** " .. playerInfo.jobLabel .. " (" .. playerInfo.job .. ")\n" ..
                      "> **Bank:** $" .. playerInfo.bank .. "\n" ..
                      "> **Cash:** $" .. playerInfo.cash .. "\n" ..
                      "> **Group:** " .. playerInfo.group .. "\n\n" ..
                      "**Entity Information:**\n" ..
                      "> **Total detected:** " .. detected .. "\n" ..
                      "> **Total deleted:** " .. deleted .. "\n" ..
                      "> **Details:** " .. jsonEncodeDetails(details),
        color = 16711680,
        image = { url = logoURL },
        thumbnail = { url = logoURL }
    }

    PerformHttpRequest(webhookURL, function(err)
        print("Webhook request complete. Error code: " .. tostring(err))
    end, 'POST', json.encode({
        username = "Entity Deletion Logs",
        avatar_url = logoURL,
        embeds = { embed }
    }), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('server:logDeletedEntities')
AddEventHandler('server:logDeletedEntities', function(entityType, detected, deleted, modelHash, coords, heading)
    local src = source
    local player = {}

    if Config.Framework == "ESX" or Config.Framework == "NewESX" then
        local xPlayer = Framework.GetPlayerFromId(src)
        if not xPlayer then
            print("ESX player not found for source:", src)
            return
        end
        player = {
            id = src,
            identifier = xPlayer.getIdentifier(),
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money,
            job = xPlayer.getJob().name,
            jobLabel = xPlayer.getJob().label,
            group = xPlayer.getGroup() or "Unknown"
        }
    else
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then
            print("QBCore player not found for source:", src)
            return
        end
        player = {
            id = src,
            identifier = Player.PlayerData.citizenid,
            cash = Player.PlayerData.money['cash'],
            bank = Player.PlayerData.money['bank'],
            job = Player.PlayerData.job.name,
            jobLabel = Player.PlayerData.job.label,
            group = Player.PlayerData.metadata.group or "Unknown"
        }
    end

    local details = { modelHash = modelHash, coords = coords, heading = heading }
    sendToWebhook(entityType, detected, deleted, details, createPlayerInfo(player))
end)








Callback('getCharacterInfo', function(source, cb)
    local identifier, cash, bank, cryptoBalance, job, jobLabel, group, totalPlayers, playerName
    totalPlayers = #GetPlayers()
    if not source or source == 0 then
        print("Invalid source provided")
        return cb(nil) 
    end
    playerName = GetPlayerName(source)
    if not playerName then
        print("Could not retrieve player name")
        return cb(nil) 
    end
    if Config.Framework == "ESX" or Config.Framework == "NewESX" then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            identifier = xPlayer.getIdentifier()
            cash = xPlayer.getMoney()          
            bank = xPlayer.getAccount('bank').money 
            cryptoBalance = xPlayer.getAccount('crypto') and xPlayer.getAccount('crypto').money or 0.0
            job = xPlayer.getJob().name
            jobLabel = xPlayer.getJob().label 
            group = xPlayer.getGroup()
        else
            print("ESX player not found for source:", source)
            return cb(nil) 
        end
        
    else 
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            identifier = Player.PlayerData.citizenid
            cash = Player.PlayerData.money['cash']    
            bank = Player.PlayerData.money['bank']  
            cryptoBalance = Player.PlayerData.money['crypto'] or 0.0
            job = Player.PlayerData.job.name
            jobLabel = Player.PlayerData.job.label 
            group = Player.PlayerData.metadata.group
        else
            print("QBCore player not found for source:", source)
            return cb(nil) 
        end
    end
    local characterInfo = {
        name = playerName,
        money = cash,
        bankBalance = bank,
        cryptoBalance = cryptoBalance,
        jobName = job,
        jobLabel = jobLabel,
        group = group,
        activePlayers = totalPlayers
    }
    cb(characterInfo)
end)



AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local data = ensureBanListExists()
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            local alreadyInList = false
            for _, p in ipairs(data.banList) do
                if p.identifier == playerIdentifier then
                    alreadyInList = true
                    break
                end
            end
            if not alreadyInList then
                table.insert(data.banList, {identifier = playerIdentifier, name = GetPlayerName(playerId), login = true})
            end
        end

        SaveResourceFile(GetCurrentResourceName(), "/menu.json", json.encode(data), -1)
    end
end)


function notAdmin(source)
    local identifier
    if Config.Framework == "ESX" or Config.Framework == "NewESX" then
        local player = Framework.GetPlayerFromId(source)
        identifier = player.getIdentifier()
    elseif Config.Framework == "QBCore" or Config.Framework == "OLDQBCore" then
        local player = Framework.Functions.GetPlayer(source)
        identifier = player.PlayerData.citizenid
    else
        identifier = GetPlayerIdentifier(source, 1) 
    end
    for _, v in pairs(Config.Admin) do
        if v == identifier then
            return true 
        end
    end
    return false 
end

Callback('GetBanAndUnbanLists', function(source, cb)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "/menu.json")) or { banList = {}, unbanList = {} }
    if notAdmin(source) then
        print("User is not an admin, loading ban and unban lists.") 
        cb({
            banList = data.banList or {},
            unbanList = data.unbanList or {}
        })
    else
        print("User is an admin or higher, access denied.") 
        cb(false)
    end
end)



Callback('BanPlayer', function(source, cb, playerData)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "/menu.json")) or { banList = {}, unbanList = {} }
    local alreadyBanned = false
    for _, p in ipairs(data.banList) do
        if p.identifier == playerData.identifier then
            p.login = false
            alreadyBanned = true
            break
        end
    end
    if not alreadyBanned then
        table.insert(data.banList, {identifier = playerData.identifier, name = playerData.name, reason = playerData.reason, login = false})
    end
    for i, p in ipairs(data.unbanList) do
        if p.identifier == playerData.identifier then
            table.remove(data.unbanList, i)
            break
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "/menu.json", json.encode(data), -1)
    local playerSource = nil
    for _, playerId in ipairs(GetPlayers()) do
        local identifiers = GetPlayerIdentifiers(playerId)
        for _, id in ipairs(identifiers) do
            if id == playerData.identifier then
                playerSource = playerId
                break
            end
        end
        if playerSource then break end
    end
    if playerSource then
        DropPlayer(playerSource, "You are banned from the server. Reason: " .. (playerData.reason or "Reason not specified"))
    end
    cb({
        banList = data.banList or {},
        unbanList = data.unbanList or {}
    })
end)



Callback('UnbanPlayer', function(source, cb, playerData)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "/menu.json")) or { banList = {}, unbanList = {} }
    for _, p in ipairs(data.banList) do
        if p.identifier == playerData.identifier then
            p.login = true
            break
        end
    end

    for i, p in ipairs(data.unbanList) do
        if p.identifier == playerData.identifier then
            table.remove(data.unbanList, i)
            break
        end
    end

    SaveResourceFile(GetCurrentResourceName(), "/menu.json", json.encode(data), -1)

    cb({
        banList = data.banList or {},
        unbanList = data.unbanList or {}
    })
end)
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerIdentifier = GetPlayerIdentifier(source)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "/menu.json")) or { banList = {}, unbanList = {} }
    local alreadyInList = false
    deferrals.defer()  
    for _, p in ipairs(data.banList) do
        if p.identifier == playerIdentifier then
            if p.login then
                deferrals.done("You are banned from this server.")
                return
            end
            alreadyInList = true
            break
        end
    end
    if not alreadyInList then
        table.insert(data.banList, {identifier = playerIdentifier, name = GetPlayerName(source), login = false})
        SaveResourceFile(GetCurrentResourceName(), "/menu.json", json.encode(data), -1)
    end
    deferrals.done()  
end)


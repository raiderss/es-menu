Config = {
    Framework = 'QBCore',  -- QBCore or ESX or OLDQBCore or NewESX
    Webhook = '',
    Logo = 'https://r2.fivemanage.com/2P9FjNbfkvdwqJtyhr4v5/sitelogo.webp',
    Admin = {
        'USF03106' 
    }
}

function GetFramework()
    local Get = nil
    if Config.Framework == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    end
    if Config.Framework == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    end
    if Config.Framework == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    end
    if Config.Framework == "OLDQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
end

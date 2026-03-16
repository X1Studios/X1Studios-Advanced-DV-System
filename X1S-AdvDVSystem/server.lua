AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    print([[
 __   __  __   ____  
 \ \ / / /_ | / ___| 
  \ V /   | | \___ \ 
  / _ \   | |  ___) |
 /_/ \_\  |_| |____/ 

 X1Studios DV System
       v1.0.0
    ]])
end)

-------------------------------------------------
-- Script Code
-------------------------------------------------
function GetDiscordId(src)
    for _,id in pairs(GetPlayerIdentifiers(src)) do
        if string.find(id,"discord:") then
            return string.gsub(id,"discord:","")
        end
    end
end

function SendWebhook(title,msg)

    if Config.Webhook == "" then return end

    PerformHttpRequest(Config.Webhook,function() end,"POST",json.encode({
        username="X1Studios DV Logs",
        embeds={{
            title=title,
            description=msg,
            color=16711680
        }}
    }),{["Content-Type"]="application/json"})
end

function GetDiscordRoles(user)

    local endpoint = ("https://discord.com/api/guilds/%s/members/%s"):format(Config.GuildID,user)

    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bot "..Config.BotToken
    }

    local p = promise.new()

    PerformHttpRequest(endpoint,function(err,text)

        if err ~= 200 then
            p:resolve(nil)
            return
        end

        local data = json.decode(text)
        p:resolve(data.roles)

    end,"GET","",headers)

    return Citizen.Await(p)
end

function HasRole(roles)

    for _,role in pairs(roles) do
        for _,allowed in pairs(Config.AllowedRoles) do
            if role == allowed then
                return true
            end
        end
    end

    return false
end

RegisterServerEvent("x1_dv:deleteVehicle")
AddEventHandler("x1_dv:deleteVehicle",function()

    local src = source
    TriggerClientEvent("x1_dv:deleteVehicleClient",src)

end)

RegisterCommand("dvall", function(source)

    local discord = GetDiscordId(source)

    if not discord then
        TriggerClientEvent("x1_dv:notify", source, "No Permissions")
        return
    end

    local roles = GetDiscordRoles(discord)

    if roles and HasRole(roles) then

        TriggerClientEvent("x1_dv:countdown", -1, Config.WipeCountdown)

        Wait(Config.WipeCountdown * 1000)

        TriggerClientEvent("x1_dv:deleteAll", -1)

        SendWebhook(
            "Vehicle Wipe",
            GetPlayerName(source).." used /dvall"
        )

    else
        TriggerClientEvent("x1_dv:notify", source, "No Permissions")
    end

end)

-------------------------------------------------
-- Update Checker
-------------------------------------------------
local resourceName = GetCurrentResourceName()
local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

local versionUrl = "https://raw.githubusercontent.com/X1Studios/X1Studios-DV-System/main/version.txt"

local function CheckForUpdates()
    PerformHttpRequest(versionUrl, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            print("^1[Update Checker] Unable to check for updates (HTTP Error " .. statusCode .. ")^0")
            return
        end

        local latestVersion = responseText:gsub("%s+", "")

        if latestVersion == currentVersion then
            print("^2[Update Checker] " .. resourceName .. " is up to date! (v" .. currentVersion .. ")^0")
        else
            print("^3-------------------------------------------------------^0")
            print("^1[Update Checker] Update Available for " .. resourceName .. "!^0")
            print("^3Current Version:^0 " .. currentVersion)
            print("^2Latest Version:^0 " .. latestVersion)
            print("^5Download:^0 https://github.com/X1Studios/X1Studios-DV-System")
            print("^3-------------------------------------------------------^0")
        end
    end, "GET")
end

CreateThread(function()
    Wait(3000)
    CheckForUpdates()
end)
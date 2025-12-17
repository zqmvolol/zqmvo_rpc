local playersCount, maxPlayers, queue, street = 0, 0, 0, ""
local playerId = GetPlayerServerId(PlayerId())

-- Configuration for RPC buttons (customizable)
local Config = {
    buttons = {
        {
            label = "Kayden's Dev Studios!",
            url = "https://discord.gg/kaydensdevelopment"  -- Replace with your server connect URL
        },
        {
            label = "Socials",
            url = "feds.lol/zqmvo"  -- Replace with your Discord invite
        }
    },
    updateInterval = 1000,  -- Update interval in milliseconds
    showCoordinates = false,   -- Show player coordinates
    showPlayerId = true,      -- Show player server ID
    showStreet = true,        -- Show street name
    showPlayerCount = true,   -- Show player count
    showQueue = true          -- Show queue size
}

local UpdateRichPresence = function(p, m, q, s, coords) 
    playersCount = p or playersCount  
    maxPlayers = m or maxPlayers      
    queue = q or queue                
    street = s or street             
    
    -- Build the rich presence text
    local details = ""
    local state = ""
    
    if Config.showStreet and street ~= "" then
        details = "📍 " .. street
    end
    
    -- Build state string with configurable elements
    local stateElements = {}
    
    if Config.showPlayerId then
        table.insert(stateElements, "ID: " .. playerId)
    end
    
    if Config.showPlayerCount then
        table.insert(stateElements, "Players: " .. tostring(playersCount) .. "/" .. tostring(maxPlayers))
    end
    
    if Config.showQueue and queue > 0 then
        table.insert(stateElements, "Queue: " .. tostring(queue))
    end
    
    if Config.showCoordinates and coords then
        table.insert(stateElements, "Coords: " .. coords)
    end
    
    state = table.concat(stateElements, " | ")
    
    -- Set the rich presence
    SetRichPresence(details ..  (details ~= "" and "\n" or "") .. state)
end

AddStateBagChangeHandler("playersCount", nil, function(_, _, value)
    UpdateRichPresence(value, nil, nil, nil, nil)
end)

AddStateBagChangeHandler("maxPlayers", nil, function(_, _, value)
    UpdateRichPresence(nil, value, nil, nil, nil)
end)

AddStateBagChangeHandler("queue", nil, function(_, _, value)
    UpdateRichPresence(nil, nil, value, nil, nil)
end)

CreateThread(function()
    -- Set Discord Application ID and Assets
    SetDiscordAppId("1387377668508352532") -- Replace with your application's ID
    SetDiscordRichPresenceAsset("Discord.gg/scamlanta") -- Main image next to the text content
    SetDiscordRichPresenceAssetText("Welcome to our server!") -- Text displayed on image hover
    SetDiscordRichPresenceAssetSmall("logo") -- Small image next to the text content
    SetDiscordRichPresenceAssetSmallText("Online Now") -- Text displayed on small image hover
    
    -- Set RPC buttons if configured
    if Config.buttons and #Config.buttons > 0 then
        for i, button in ipairs(Config.buttons) do
            if i == 1 then
                SetDiscordRichPresenceAction(0, button.label, button.url)
            elseif i == 2 then
                SetDiscordRichPresenceAction(1, button.label, button.url)
            end
            -- Discord RPC only supports up to 2 buttons
            if i >= 2 then break end
        end
    end

    -- Get initial player ID
    playerId = GetPlayerServerId(PlayerId())
    
    -- Trigger server event to register player
    TriggerServerEvent("pm_queue")

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local coordsString = ""
        
        if Config.showCoordinates then
            coordsString = string.format("%.0f, %.0f, %.0f", playerCoords.x, playerCoords.y, playerCoords.z)
        end
        
        local streetName = ""
        if Config.showStreet then
            local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
            streetName = GetStreetNameFromHashKey(streetHash)
        end

        UpdateRichPresence(GlobalState.playersCount, GlobalState.maxPlayers, GlobalState.queue, streetName, coordsString)

        Citizen.Wait(Config.updateInterval)
    end
end)

-- Command to toggle coordinate display
RegisterCommand("togglecoords", function()
    Config.showCoordinates = not Config.showCoordinates
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = true,
        args = {"Discord RPC", "Coordinates display: " .. (Config.showCoordinates and "ON" or "OFF")}
    })
end, false)

-- Command to toggle player ID display
RegisterCommand("toggleid", function()
    Config.showPlayerId = not Config.showPlayerId
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = true,
        args = {"Discord RPC", "Player ID display: " .. (Config.showPlayerId and "ON" or "OFF")}
    })
end, false)

-- Command to manually update RPC
RegisterCommand("updaterpc", function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local coordsString = ""
    
    if Config.showCoordinates then
        coordsString = string.format("%.0f, %.0f, %.0f", playerCoords.x, playerCoords.y, playerCoords.z)
    end
    
    local streetName = ""
    if Config.showStreet then
        local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
        streetName = GetStreetNameFromHashKey(streetHash)
    end
    
    UpdateRichPresence(GlobalState.playersCount, GlobalState.maxPlayers, GlobalState.queue, streetName, coordsString)
    
    TriggerEvent("chat:addMessage", {
        color = { 0, 255, 0 },
        multiline = true,
        args = {"Discord RPC", "Rich presence updated manually!"}
    })
end, false)
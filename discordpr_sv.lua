local list, count = {}, 0

-- Configuration for queue system
local Config = {
    enableQueue = true,  -- Enable/disable queue system
    maxPlayers = GetConvarInt("sv_maxclients", 32)
}

AddEventHandler("playerDropped", function()
    if list[source] then
        count = count - 1
        list[source] = nil
        GlobalState:set("playersCount", count, true)
        
        -- Update queue if enabled
        if Config.enableQueue then
            -- You can add queue management logic here
            GlobalState:set("queue", 0, true) -- Set to actual queue count from your queue system
        end
    end
end)

RegisterServerEvent("pm_queue", function()
    if not list[source] then
        count = count + 1
        list[source] = count
        GlobalState:set("playersCount", count, true)
    end
end)

-- Event to update queue size (call this from your queue system)
RegisterServerEvent("discord:updateQueue", function(queueSize)
    if Config.enableQueue then
        GlobalState:set("queue", queueSize or 0, true)
    end
end)

-- Export function to update queue from other resources
exports('updateQueue', function(queueSize)
    if Config.enableQueue then
        GlobalState:set("queue", queueSize or 0, true)
    end
end)

-- Export function to get current player count
exports('getPlayerCount', function()
    return count
end)

-- Export function to get max players
exports('getMaxPlayers', function()
    return Config.maxPlayers
end)

CreateThread(function()
    GlobalState:set("maxPlayers", Config.maxPlayers, true)
    GlobalState:set("queue", 0, true) -- Initialize queue to 0
    
    -- Optional: Update player count every minute as a fallback
    while true do
        Citizen.Wait(60000) -- Wait 1 minute
        
        -- Verify player count matches actual online players
        local actualCount = #GetPlayers()
        if count ~= actualCount then
            print("^3[Discord RPC] Player count mismatch detected. Correcting: " .. count .. " -> " .. actualCount .. "^7")
            count = actualCount
            GlobalState:set("playersCount", count, true)
        end
    end
end)

-- Command for admins to manually set queue size (useful for testing)
RegisterCommand("setqueue", function(source, args)
    local player = source
    
    -- Check if player has admin permissions (implement your own permission check)
    if IsPlayerAceAllowed(player, "discord.admin") or player == 0 then -- player == 0 means console
        local queueSize = tonumber(args[1])
        if queueSize and queueSize >= 0 then
            GlobalState:set("queue", queueSize, true)
            if player == 0 then
                print("^2[Discord RPC] Queue size set to: " .. queueSize .. "^7")
            else
                TriggerClientEvent("chat:addMessage", player, {
                    color = { 0, 255, 0 },
                    multiline = true,
                    args = {"Discord RPC", "Queue size set to: " .. queueSize}
                })
            end
        else
            if player == 0 then
                print("^1[Discord RPC] Invalid queue size. Please provide a valid number.^7")
            else
                TriggerClientEvent("chat:addMessage", player, {
                    color = { 255, 0, 0 },
                    multiline = true,
                    args = {"Discord RPC", "Invalid queue size. Please provide a valid number."}
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", player, {
            color = { 255, 0, 0 },
            multiline = true,
            args = {"Discord RPC", "You don't have permission to use this command."}
        })
    end
end, false)

-- Command to get current RPC stats
RegisterCommand("rpcstats", function(source, args)
    local player = source
    local statsMessage = string.format("Players: %d/%d | Queue: %d", 
        count, Config.maxPlayers, GlobalState.queue or 0)
    
    if player == 0 then
        print("^2[Discord RPC Stats] " .. statsMessage .. "^7")
    else
        TriggerClientEvent("chat:addMessage", player, {
            color = { 0, 255, 255 },
            multiline = true,
            args = {"Discord RPC Stats", statsMessage}
        })
    end
end, false)
local playerCount = 0
local queueCount = 0
local maxPlayers = GetConvarInt("sv_maxclients", 64)

-- Queue system detection and integration
local QueueIntegration = {
    detectedSystem = "none",
    checkInterval = 5000, -- Check queue every 5 seconds
}

-- Supported queue systems and their detection
local QueueSystems = {
    {
        name = "connectqueue",
        resource = "connectqueue",
        export = "getQueueCount",
        getQueue = function()
            local success, result = pcall(function()
                return exports.connectqueue:getQueueCount()
            end)
            return success and result or 0
        end
    },
    {
        name = "txAdmin",
        resource = "txAdmin",
        export = "getQueueSize",
        getQueue = function()
            local success, result = pcall(function()
                return exports.txAdmin:getQueueSize()
            end)
            return success and result or 0
        end
    },
    {
        name = "Badger_Queue",
        resource = "Badger_Queue",
        export = "getQueueSize",
        getQueue = function()
            local success, result = pcall(function()
                return exports['Badger_Queue']:getQueueSize()
            end)
            return success and result or 0
        end
    },
    {
        name = "hardcap",
        resource = "hardcap",
        export = "getQueueCount",
        getQueue = function()
            local success, result = pcall(function()
                return exports.hardcap:getQueueCount()
            end)
            return success and result or 0
        end
    },
    {
        name = "qb-queue",
        resource = "qb-queue",
        export = "GetQueueSize",
        getQueue = function()
            local success, result = pcall(function()
                return exports['qb-queue']:GetQueueSize()
            end)
            return success and result or 0
        end
    },
    {
        name = "esx_queue",
        resource = "esx_queue",
        export = "getQueueCount",
        getQueue = function()
            local success, result = pcall(function()
                return exports.esx_queue:getQueueCount()
            end)
            return success and result or 0
        end
    }
}

-- Detect which queue system is running
local function DetectQueueSystem()
    for _, system in ipairs(QueueSystems) do
        local resourceState = GetResourceState(system.resource)
        if resourceState == "started" or resourceState == "starting" then
            print("^2[Discord RPC] Detected queue system: " .. system.name .. "^7")
            QueueIntegration.detectedSystem = system.name
            return system
        end
    end
    print("^3[Discord RPC] No queue system detected - queue display disabled^7")
    return nil
end

-- Get queue count from detected system
local function GetQueueCount()
    if QueueIntegration.detectedSystem == "none" then
        return 0
    end
    
    for _, system in ipairs(QueueSystems) do
        if system.name == QueueIntegration.detectedSystem then
            local count = system.getQueue()
            return count or 0
        end
    end
    
    return 0
end

-- Update player count (doesn't interfere with connections)
local function UpdatePlayerCount()
    local players = GetPlayers()
    playerCount = #players
    GlobalState:set("playersCount", playerCount, true)
end

-- Update queue count
local function UpdateQueueCount()
    queueCount = GetQueueCount()
    GlobalState:set("queue", queueCount, true)
end

-- Player connecting (for accurate tracking, doesn't block)
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    -- Don't defer or block, just update count
    CreateThread(function()
        Wait(100)
        UpdatePlayerCount()
    end)
end)

-- Player joined
RegisterServerEvent("pm_queue", function()
    UpdatePlayerCount()
end)

AddEventHandler("playerJoining", function()
    UpdatePlayerCount()
end)

-- Player dropped
AddEventHandler("playerDropped", function(reason)
    CreateThread(function()
        Wait(100)
        UpdatePlayerCount()
        UpdateQueueCount()
    end)
end)

-- Export functions for other resources to use
exports('updateQueue', function(queueSize)
    if queueSize then
        queueCount = queueSize
        GlobalState:set("queue", queueCount, true)
    end
    return queueCount
end)

exports('getPlayerCount', function()
    return playerCount
end)

exports('getMaxPlayers', function()
    return maxPlayers
end)

exports('getQueueCount', function()
    return queueCount
end)

-- Manual queue update event (for custom queue systems)
RegisterServerEvent("discord:updateQueue", function(queueSize)
    if queueSize and queueSize >= 0 then
        queueCount = queueSize
        GlobalState:set("queue", queueCount, true)
    end
end)

-- Initialize and main loop
CreateThread(function()
    -- Wait for all resources to start
    Wait(5000)
    
    -- Detect queue system
    local queueSystem = DetectQueueSystem()
    
    -- Set initial global states
    GlobalState:set("maxPlayers", maxPlayers, true)
    GlobalState:set("queue", 0, true)
    GlobalState:set("playersCount", 0, true)
    
    print("^2[Discord RPC] Initialized - Max Players: " .. maxPlayers .. "^7")
    
    -- Initial update
    UpdatePlayerCount()
    UpdateQueueCount()
    
    -- Main update loop
    while true do
        Wait(QueueIntegration.checkInterval)
        
        -- Update player count
        UpdatePlayerCount()
        
        -- Update queue count if we have a queue system
        if queueSystem then
            UpdateQueueCount()
        end
    end
end)

-- Fallback: verify counts every minute
CreateThread(function()
    while true do
        Wait(60000) -- 1 minute
        
        local actualPlayers = #GetPlayers()
        if playerCount ~= actualPlayers then
            print("^3[Discord RPC] Player count drift detected. Correcting: " .. playerCount .. " -> " .. actualPlayers .. "^7")
            playerCount = actualPlayers
            GlobalState:set("playersCount", playerCount, true)
        end
    end
end)

-- Admin commands
RegisterCommand("setqueue", function(source, args)
    if IsPlayerAceAllowed(source, "discord.admin") or source == 0 then
        local size = tonumber(args[1])
        if size and size >= 0 then
            queueCount = size
            GlobalState:set("queue", size, true)
            local msg = "^2[Discord RPC] Queue manually set to: " .. size .. "^7"
            if source == 0 then
                print(msg)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    color = { 0, 255, 0 },
                    args = {"Discord RPC", "Queue set to: " .. size}
                })
            end
        else
            local msg = "^1[Discord RPC] Invalid queue size^7"
            if source == 0 then
                print(msg)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    color = { 255, 0, 0 },
                    args = {"Discord RPC", "Invalid queue size"}
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = { 255, 0, 0 },
            args = {"Discord RPC", "No permission"}
        })
    end
end, false)

RegisterCommand("rpcstats", function(source)
    local stats = string.format("Players: %d/%d | Queue: %d | System: %s", 
        playerCount, maxPlayers, queueCount, QueueIntegration.detectedSystem)
    
    if source == 0 then
        print("^2[Discord RPC] " .. stats .. "^7")
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = { 0, 255, 255 },
            args = {"Discord RPC", stats}
        })
    end
end, false)

RegisterCommand("refreshrpc", function(source)
    if IsPlayerAceAllowed(source, "discord.admin") or source == 0 then
        UpdatePlayerCount()
        UpdateQueueCount()
        local msg = "^2[Discord RPC] Stats refreshed - Players: " .. playerCount .. " | Queue: " .. queueCount .. "^7"
        if source == 0 then
            print(msg)
        else
            TriggerClientEvent("chat:addMessage", source, {
                color = { 0, 255, 0 },
                args = {"Discord RPC", "Stats refreshed"}
            })
        end
    end
end, false)

-- Debug command
RegisterCommand("rpcdetect", function(source)
    if IsPlayerAceAllowed(source, "discord.admin") or source == 0 then
        local queueSystem = DetectQueueSystem()
        if source == 0 then
            print("^2[Discord RPC] Queue detection complete^7")
        else
            TriggerClientEvent("chat:addMessage", source, {
                color = { 0, 255, 0 },
                args = {"Discord RPC", "Detected: " .. (queueSystem and queueSystem.name or "none")}
            })
        end
    end
end, false)

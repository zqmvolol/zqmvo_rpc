#  Discord Rich Presence for FiveM

A feature-rich Discord RPC system for FiveM servers with automatic queue integration, customizable buttons, and real-time player tracking.

![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## ✨ Features

### 🎯 Core Features
- **Real-time Player Count** - Displays current players vs max capacity
- **Queue System Integration** - Automatic detection and display of queue size
- **Street Name Display** - Shows current player location in-game
- **Player ID Display** - Shows server ID in Discord status
- **Customizable Buttons** - Up to 2 clickable buttons (Discord invite, website, etc.)
- **Coordinate Display** - Optional player coordinate display (toggle-able)

### 🔄 Queue System Support
Automatically detects and integrates with:
- ✅ **connectqueue** - Most common FiveM queue
- ✅ **txAdmin Queue** - Built-in txAdmin queue
- ✅ **Badger_Queue** - Popular queue system
- ✅ **hardcap** - Basic hardcap queue
- ✅ **qb-queue** - QBCore queue system
- ✅ **esx_queue** - ESX queue system
- ✅ **Custom Queues** - Easy integration via events/exports

### 🎨 Customization
- Toggle individual display elements (coords, ID, street, player count)
- Configurable update intervals
- Custom button labels and URLs
- Custom Discord application assets

## 📋 Requirements

- FiveM Server
- ox_lib
- oxmysql (for database features)

## 🚀 Installation

1. **Download** the resource and place it in your `resources` folder

2. **Configure Discord Application**
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Create a new application
   - Copy your Application ID
   - Upload assets (images) in the "Rich Presence" section

3. **Edit `discordpr_cl.lua`**
   ```lua
   SetDiscordAppId("YOUR_APPLICATION_ID") -- Replace with your Discord App ID
   SetDiscordRichPresenceAsset("main_image") -- Your main image asset name
   SetDiscordRichPresenceAssetText("Welcome to our server!")
   SetDiscordRichPresenceAssetSmall("small_logo") -- Your small image asset name
   SetDiscordRichPresenceAssetSmallText("Online Now")
   ```

4. **Configure Buttons** (Optional)
   ```lua
   local Config = {
       buttons = {
           {
               label = "Join Our Discord!",
               url = "https://discord.gg/your-invite"
           },
           {
               label = "Visit Website",
               url = "https://yourserver.com"
           }
       }
   }
   ```

5. **Add to `server.cfg`**
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure your-queue-system  # Load your queue system BEFORE discord RPC
   ensure zqmvo_discord
   ```

6. **Restart** your server

## ⚙️ Configuration

### Client-Side (`discordpr_cl.lua`)

```lua
local Config = {
    buttons = {
        {
            label = "Join Discord",
            url = "https://discord.gg/your-invite"
        },
        {
            label = "Website",
            url = "https://yourserver.com"
        }
    },
    updateInterval = 1000,      -- Update frequency (milliseconds)
    showCoordinates = false,    -- Show player coordinates
    showPlayerId = true,        -- Show player server ID
    showStreet = true,          -- Show street name
    showPlayerCount = true,     -- Show player count
    showQueue = true            -- Show queue size
}
```

### Server-Side (Automatic)
- Automatically reads `sv_maxclients` from your server.cfg
- Auto-detects queue system on startup
- No manual configuration needed!

## 🎮 Commands

### Admin Commands
| Command | Description |
|---------|-------------|
| `/togglecoords` | Toggle coordinate display on/off |
| `/toggleid` | Toggle player ID display on/off |
| `/updaterpc` | Manually update Rich Presence |
| `/rpcstats` | View detailed RPC statistics | Any |
| `/setqueue <number>` | Manually set queue size | `discord.admin` |
| `/refreshrpc` | Force refresh all counts | `discord.admin` |
| `/rpcdetect` | Re-run queue system detection | `discord.admin` |

## 🔌 Custom Queue Integration

### For Custom Queue Systems

**Method 1: Using Events**
```lua
-- In your queue system, when queue size changes:
TriggerEvent("discord:updateQueue", queueSize)
```

**Method 2: Using Exports**
```lua
-- In your queue system:
exports['discord-rpc-resource']:updateQueue(queueSize)
```

**Method 3: Add to Auto-Detection**
Edit `discordpr_sv.lua` and add your system to the `QueueSystems` table:
```lua
{
    name = "your_queue_name",
    resource = "your_queue_resource",
    export = "yourExportFunction",
    getQueue = function()
        local success, result = pcall(function()
            return exports['your_queue_resource']:yourExportFunction()
        end)
        return success and result or 0
    end
}
```

## 📊 Exports

### Server-Side Exports

```lua
-- Update queue count from external resource
exports['discord-rpc']:updateQueue(queueSize)

-- Get current player count
local players = exports['discord-rpc']:getPlayerCount()

-- Get max players
local max = exports['discord-rpc']:getMaxPlayers()

-- Get current queue count
local queue = exports['discord-rpc']:getQueueCount()
```

## 🐛 Troubleshooting

### Queue shows 0 even with people in queue
1. Check server console for: `[Discord RPC] Detected queue system: [name]`
2. If it says "No queue system detected":
   - Ensure your queue resource starts BEFORE discord RPC
   - Use `/rpcdetect` to re-scan for queue systems
   - Check your queue resource name matches supported systems

### Player count incorrect
1. Use `/refreshrpc` to force update
2. Check F8 console for errors
3. Script auto-corrects every 60 seconds

### Max players showing wrong number
- Verify `sv_maxclients` is set correctly in `server.cfg`
- Restart the resource after changing `sv_maxclients`
- Check startup message: `[Discord RPC] Max Players set to: X`

### Discord not updating
1. Verify your Discord Application ID is correct
2. Check that assets are uploaded in Discord Developer Portal
3. Restart Discord client
4. Use `/updaterpc` to force update

## 📝 Example Discord Status

```
🏙️ Vinewood Blvd
ID: 42 | Players: 45/64 | Queue: 3
```

With buttons:
- [Join Discord]
- [Visit Store]

## 🔄 Recent Updates

### Version 2.1.0
- ✅ Fixed max player detection (was stuck at 30/32)
- ✅ Added automatic queue system detection
- ✅ Fixed connection blocking issues
- ✅ Improved player count accuracy
- ✅ Added support for 6 major queue systems
- ✅ New admin commands for debugging
- ✅ Better error handling with pcall
- ✅ Performance optimizations

See [CHANGELOG.md](CHANGELOG.md) for full version history.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Support

- **Issues**: Open an issue on Discord
- **Discord**: Join our [Discord server](https://discord.gg/sdyruNpXpA)

## 🙏 Credits

**Author**: zqmvo

**Special Thanks**:
- Community for reporting bugs and suggesting features
- Queue system developers for making integration possible
- FiveM community for testing and feedback


---

**Note**: Replace placeholder URLs, Discord invites, and application IDs with your actual information before using!

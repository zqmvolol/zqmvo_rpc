# Discord Rich Presence for FiveM

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange.svg)

An enhanced Discord Rich Presence resource for FiveM servers with customizable buttons, real-time player information, and queue system integration.

## ✨ Features

- 🎮 **Dynamic Rich Presence** - Real-time updates of player status
- 📍 **Location Tracking** - Displays current street name
- 👥 **Player Count** - Shows current players vs max capacity
- 🎫 **Queue Integration** - Compatible with queue systems
- 🔘 **Custom Buttons** - Up to 2 customizable buttons with links
- 🆔 **Player ID Display** - Shows server ID in Rich Presence
- 📊 **Coordinate Display** - Optional coordinate tracking (toggle-able)
- ⚙️ **Highly Configurable** - Easy customization options
- 📡 **State Management** - Uses GlobalState for efficient updates
- 🛠️ **Admin Commands** - Built-in commands for management

## 📋 Requirements

- [ox_lib](https://github.com/overextended/ox_lib) - Core dependency
- [oxmysql](https://github.com/overextended/oxmysql) - Database wrapper
- Discord Application (for custom Rich Presence)

## 🚀 Installation

1. **Download** the resource and place it in your server's `resources` folder

2. **Create a Discord Application**:
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application"
   - Name your application (this will show in Rich Presence)
   - Navigate to "Rich Presence" → "Art Assets"
   - Upload your images (recommended: 1024x1024px)
   - Note your Application ID

3. **Configure the Resource**:
   - Open `discordpr_cl.lua`
   - Replace the Application ID on line 79:
     ```lua
     SetDiscordAppId("YOUR_APPLICATION_ID_HERE")
     ```
   - Update the asset names to match your uploaded images:
     ```lua
     SetDiscordRichPresenceAsset("your_main_image_name")
     SetDiscordRichPresenceAssetSmall("your_small_image_name")
     ```
   - Customize the buttons (lines 10-17):
     ```lua
     buttons = {
         {
             label = "Join Server",
             url = "fivem://connect/your-server-ip"
         },
         {
             label = "Discord",
             url = "https://discord.gg/your-invite"
         }
     }
     ```

4. **Add to server.cfg**:
   ```
   ensure ox_lib
   ensure oxmysql
   ensure discord-rpc
   ```

## ⚙️ Configuration

### Client Configuration (`discordpr_cl.lua`)

```lua
local Config = {
    buttons = {
        {
            label = "Join Server",              -- Button text
            url = "fivem://connect/your-ip"     -- Connect link
        },
        {
            label = "Discord",                   -- Button text
            url = "https://discord.gg/invite"   -- Discord invite
        }
    },
    updateInterval = 1000,        -- Update frequency (ms)
    showCoordinates = false,      -- Show player coordinates
    showPlayerId = true,          -- Show player server ID
    showStreet = true,            -- Show street name
    showPlayerCount = true,       -- Show player count
    showQueue = true              -- Show queue size
}
```

### Server Configuration (`discordpr_sv.lua`)

```lua
local Config = {
    enableQueue = true,  -- Enable/disable queue system
    maxPlayers = GetConvarInt("sv_maxclients", 32)
}
```

## 🎮 Commands

### Player Commands

| Command | Description |
|---------|-------------|
| `/togglecoords` | Toggle coordinate display in Rich Presence |
| `/toggleid` | Toggle player ID display in Rich Presence |
| `/updaterpc` | Manually refresh Rich Presence |
| `/rpcstats` | View current server statistics |

### Admin Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/setqueue` | `/setqueue <number>` | Manually set queue size (requires `discord.admin` ace permission) |

## 📡 Exports

### Server Exports

```lua
-- Update queue size from another resource
exports['discord-rpc']:updateQueue(queueSize)

-- Get current player count
local playerCount = exports['discord-rpc']:getPlayerCount()

-- Get max players
local maxPlayers = exports['discord-rpc']:getMaxPlayers()
```

### Example Queue Integration

```lua
-- In your queue resource
local queueSize = #GetQueueList() -- Your queue function
exports['discord-rpc']:updateQueue(queueSize)
```

## 🎨 Discord Application Setup

### Creating Your Application

1. **Application Name**: This appears as "Playing [Your Application Name]"
2. **Application ID**: Found in "General Information"
3. **Rich Presence Assets**: Upload under "Rich Presence" → "Art Assets"
   - Main image: Large image next to text (1024x1024 recommended)
   - Small image: Small overlay image (512x512 recommended)

### Asset Guidelines

- **Format**: PNG or JPG
- **Size**: 1024x1024px (main), 512x512px (small)
- **Name**: Use lowercase, no spaces (e.g., `server_logo`, `online_icon`)

## 📸 Rich Presence Display Example

```
Playing Chicago Loop Roleplay
📍 Vinewood Boulevard
ID: 42 | Players: 45/64 | Queue: 3
```

## 🔧 Troubleshooting

### Rich Presence Not Showing

1. Verify Discord Application ID is correct
2. Check that asset names match exactly (case-sensitive)
3. Ensure Discord is running on the same machine as FiveM
4. Restart FiveM client after configuration changes

### Player Count Incorrect

- Use `/rpcstats` command to check current values
- Server automatically corrects mismatches every minute
- Check server console for correction messages

### Queue Not Updating

- Ensure `enableQueue` is set to `true` in server config
- Verify your queue system calls the export function
- Test with `/setqueue <number>` command

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- **Author**: zqmvo
- **Version**: 2.0
- **Discord**: [Kayden's Dev Studios](https://discord.gg/kaydensdevelopment)

## 📞 Support

For support, join our Discord: [discord.gg/kaydensdevelopment](https://discord.gg/kaydensdevelopment)

## 📋 Changelog

### Version 2.0
- Enhanced customizable button system
- Improved GlobalState management
- Added toggle commands for coordinates and player ID
- Implemented admin commands for queue management
- Added automatic player count verification
- Enhanced export functions
- Improved error handling and fallbacks
- Better documentation and configuration options

---

**Note**: Remember to keep your Discord Application ID private and never commit it to public repositories. Consider using environment variables or separate config files for sensitive information.

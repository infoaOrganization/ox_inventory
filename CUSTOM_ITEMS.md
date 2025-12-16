# Custom Item Registration for ox_inventory

This guide explains how external FiveM resources can dynamically register custom items with ox_inventory using exports.

## Overview

ox_inventory now supports dynamic item registration from external resources via the `registerItems` export. This allows you to add custom items without modifying the `data/items.lua` file. Items are automatically synced to all connected clients, including players who join later.

## Usage

### Register a Single Item

```lua
-- In your external resource (server-side only)
exports['ox_inventory']:registerItems('custom_burger', {
    label = 'Custom Burger',
    weight = 250,
    stack = true,
    close = true,
    consume = 1,
    description = 'A delicious custom burger',
    client = {
        status = { hunger = 200000 },
        anim = 'eating',
        prop = 'burger',
        usetime = 2500,
        notification = 'You ate a custom burger'
    }
})
```

### Register Multiple Items

```lua
-- In your external resource (server-side only)
exports['ox_inventory']:registerItems({
    ['diamond_ring'] = {
        label = 'Diamond Ring',
        weight = 50,
        stack = true,
        close = true,
        description = 'A beautiful diamond ring'
    },
    ['golden_watch'] = {
        label = 'Golden Watch',
        weight = 100,
        stack = true,
        close = true,
        description = 'An expensive golden watch'
    },
    ['magic_potion'] = {
        label = 'Magic Potion',
        weight = 150,
        stack = true,
        consume = 1,
        description = 'A mystical healing potion',
        client = {
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            notification = 'You feel magical energy coursing through you'
        },
        server = {
            export = 'my_resource.useMagicPotion'
        }
    }
})
```

## Item Data Structure

### Common Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `label` | string | **required** | Display name of the item |
| `weight` | number | 0 | Weight of the item in grams |
| `stack` | boolean | true | Whether the item can stack |
| `close` | boolean | true | Whether to close inventory after use |
| `description` | string | nil | Item description shown in inventory |
| `consume` | number | auto | Amount consumed on use (0-1 for durability, 1+ for count) |
| `degrade` | number | nil | Degradation time in minutes |
| `durability` | boolean | auto | Whether item has durability (auto-calculated) |

### Client-Side Configuration (`client` table)

The `client` table contains all client-side behavior for the item:

```lua
client = {
    -- Status effects when consumed (ESX framework)
    status = {
        hunger = 200000,  -- Increases hunger
        thirst = 100000,  -- Increases thirst
        stress = -50000   -- Reduces stress (negative value)
    },

    -- Animation shortcuts (predefined in ox_inventory)
    anim = 'eating',  -- or 'drinking' or custom dict/clip table
    prop = 'burger',  -- or custom prop table

    -- OR custom animation
    anim = {
        dict = 'mp_player_intdrink',
        clip = 'loop_bottle',
        flag = 49  -- optional
    },

    -- Custom prop
    prop = {
        model = `prop_ld_flow_bottle`,
        pos = vec3(0.03, 0.03, 0.02),
        rot = vec3(0.0, 0.0, -1.5)
    },

    -- Usage settings
    usetime = 2500,  -- Time in ms to use the item
    cancel = true,   -- Can cancel usage

    -- Disable controls during use
    disable = {
        move = true,    -- Disable movement
        car = true,     -- Disable vehicle use
        combat = true   -- Disable combat
    },

    -- Custom image (relative to inventory:imagepath or full URL)
    image = 'custom_item.png',  -- or 'https://example.com/image.png'

    -- Notification message
    notification = 'You used the item',

    -- Export function to call on client (format: 'resource.function')
    export = 'my_resource.clientUseItem',

    -- Event to trigger on client (alternative to export)
    event = 'my_resource:clientEvent',

    -- Custom function (defined via Item() on client-side)
    -- See "Advanced Client-Side Functions" below
}
```

### Server-Side Configuration (`server` table)

```lua
server = {
    -- Export function to call on server (format: 'resource.function')
    export = 'my_resource.serverUseItem',

    -- Custom data for your resource
    customField = 'value',
    customData = { key = 'value' }
}
```

## Animation Shortcuts

ox_inventory provides shortcuts for common animations:

| Shortcut | Description |
|----------|-------------|
| `anim = 'eating'` | Eating animation with food prop |
| `anim = 'drinking'` | Drinking animation with bottle prop |
| `prop = 'burger'` | Burger prop |
| `prop = 'bottle'` | Bottle prop |

For custom animations, use the full table format.

## Server Export Function

When using `server.export`, your function receives these parameters:

```lua
-- In my_resource/server.lua
function useMagicPotion(event, item, inventory, slot, data)
    -- event: 'usingItem' or 'usedItem'
    -- item: The item definition
    -- inventory: The player's inventory object
    -- slot: The slot number
    -- data: Additional data (for shops, etc.)

    if event == 'usingItem' then
        -- Called before item is used
        -- Return false to cancel item use
        print(('%s is about to use %s'):format(inventory.label, item.label))
        return true
    elseif event == 'usedItem' then
        -- Called after item is consumed
        print(('%s used %s from slot %s'):format(inventory.label, item.label, slot))
    end
end

exports('useMagicPotion', useMagicPotion)
```

## Advanced Client-Side Functions

For complex client-side behavior, you can define custom functions in your resource's client-side code:

```lua
-- In my_resource/client.lua
local ox_inventory = exports.ox_inventory

-- Wait for item to be registered
CreateThread(function()
    while not ox_inventory:Items('custom_healing_kit') do
        Wait(100)
    end

    -- Define custom client function
    local Items = ox_inventory:Items()
    local item = Items['custom_healing_kit']

    if item then
        item.effect = function(data, slot)
            ox_inventory:useItem(data, function(data)
                if data then
                    -- Your custom client logic here
                    local ped = PlayerPedId()
                    local health = GetEntityHealth(ped)
                    local maxHealth = GetEntityMaxHealth(ped)

                    SetEntityHealth(ped, math.min(maxHealth, health + 50))
                    lib.notify({ description = 'You used a healing kit' })
                end
            end)
        end
    end
end)
```

## Best Practices

### 1. Register items after ox_inventory starts

```lua
-- In your resource's server.lua
CreateThread(function()
    -- Wait for ox_inventory to be ready
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(100)
    end

    -- Register your items
    exports['ox_inventory']:registerItems('my_item', {
        label = 'My Item',
        weight = 100
    })
end)
```

### 2. Use unique item names

Prefix your items to avoid conflicts:
```lua
exports['ox_inventory']:registerItems('myresource_diamond', {...})
```

### 3. Always register from server-side

Item registration must be done server-side. The server will automatically sync items to all clients, including late-joining players.

### 4. Batch registration for better performance

When registering multiple items, use a single call instead of multiple calls:

```lua
-- Good - single batch call
exports['ox_inventory']:registerItems({
    ['item1'] = {...},
    ['item2'] = {...},
    ['item3'] = {...}
})

-- Avoid - multiple individual calls
exports['ox_inventory']:registerItems('item1', {...})
exports['ox_inventory']:registerItems('item2', {...})
exports['ox_inventory']:registerItems('item3', {...})
```

### 5. Define exports before registering

If using `server.export` or `client.export`, ensure the export function exists:

```lua
-- Define export first
function useMyItem(event, item, inventory, slot)
    -- Your logic
end
exports('useMyItem', useMyItem)

-- Then register item
exports['ox_inventory']:registerItems('my_item', {
    label = 'My Item',
    server = {
        export = GetCurrentResourceName() .. '.useMyItem'
    }
})
```

## Complete Example Resource

### File Structure
```
my_custom_items/
├── fxmanifest.lua
├── server.lua
└── client.lua (optional)
```

### fxmanifest.lua
```lua
fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Custom items for ox_inventory'
version '1.0.0'

dependencies {
    'ox_inventory',
    'ox_lib'
}

shared_script '@ox_lib/init.lua'

server_script 'server.lua'
client_script 'client.lua'  -- if needed
```

### server.lua
```lua
CreateThread(function()
    -- Wait for ox_inventory to start
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(100)
    end

    -- Define server-side item functions
    local function useEnergyDrink(event, item, inventory, slot)
        if event == 'usingItem' then
            print(('%s is drinking an energy drink'):format(inventory.label))
            return true
        elseif event == 'usedItem' then
            -- Could trigger effects here
            TriggerClientEvent('my_custom_items:energyBoost', inventory.id)
        end
    end
    exports('useEnergyDrink', useEnergyDrink)

    -- Register items
    exports['ox_inventory']:registerItems({
        ['energy_drink'] = {
            label = 'Energy Drink',
            weight = 350,
            stack = true,
            consume = 1,
            description = 'Gives you a boost of energy',
            client = {
                status = { thirst = 100000 },
                anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
                prop = {
                    model = `prop_energy_drink`,
                    pos = vec3(0.01, 0.01, 0.06),
                    rot = vec3(5.0, 5.0, -180.5)
                },
                usetime = 2500,
                notification = 'You feel energized!'
            },
            server = {
                export = 'my_custom_items.useEnergyDrink'
            }
        },
        ['rare_gem'] = {
            label = 'Rare Gem',
            weight = 25,
            stack = true,
            description = 'A rare and valuable gemstone',
            client = {
                image = 'rare_gem.png'  -- Place in ox_inventory/web/images/
            }
        },
        ['lockpick_advanced'] = {
            label = 'Advanced Lockpick',
            weight = 150,
            stack = false,
            durability = true,
            degrade = 60,  -- Degrades over 60 minutes
            description = 'A high-quality lockpick that lasts longer'
        }
    })

    print('Custom items registered successfully!')
end)
```

### client.lua (optional - for complex client functions)
```lua
RegisterNetEvent('my_custom_items:energyBoost', function()
    -- Add temporary speed boost or other effects
    local ped = PlayerPedId()
    SetPedMoveRateOverride(ped, 1.2)

    SetTimeout(30000, function()
        SetPedMoveRateOverride(ped, 1.0)
    end)
end)
```

## Notes

- **Items are not persisted** to `data/items.lua` - they exist only in memory
- **Items must be re-registered** each time the resource starts
- **Server syncs to clients** automatically - no client-side registration needed
- **Overwriting items** - Registering an item that already exists will overwrite it
- **ESX integration** - Assumes `es_extended` is available per dependencies

## Troubleshooting

**Items not appearing:**
- Ensure ox_inventory is started before your resource
- Check server console for errors
- Verify item data structure is correct

**Animations not working:**
- Verify animation dictionary and clip names
- Check prop model hash is correct
- Ensure `usetime` is set

**Items not syncing to clients:**
- Items are synced automatically when registered
- Check for console errors on both server and client
- Ensure `TriggerClientEvent` is working properly

## Support

For issues or questions, refer to:
- ox_inventory documentation: https://overextended.dev/ox_inventory
- ox_lib documentation: https://overextended.dev/ox_lib

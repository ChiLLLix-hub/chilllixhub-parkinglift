# ChilLLix Parking Lift

A QBCore FiveM script that creates movable platform lifts for automatic parking garages. Players can park vehicles on platforms, which will vertically descend underground, store the vehicle, and automatically return to the surface.

## Features

- ✅ Vertical platform movement with smooth animation
- ✅ Configurable movement speed and distance
- ✅ Vehicle detection on platform
- ✅ Automatic vehicle deletion (simulates storage)
- ✅ Vehicle attachment system (vehicles physically attached to platform for perfect synchronization)
- ✅ Collision-free vehicle movement (prevents slingshot effect underground)
- ✅ Synchronized movement across all clients
- ✅ Multiple lift support
- ✅ qb-target integration (optional)
- ✅ Configurable interaction zones
- ✅ Automatic platform return with configurable delay
- ✅ Optimized performance with proper resource cleanup

## Requirements

- QBCore Framework
- qb-target (optional, for interaction zones)

## Installation

1. Download or clone this repository
2. Place the `chilllixhub-parkinglift` folder in your server's `resources` directory
3. Add `ensure chilllixhub-parkinglift` to your `server.cfg`
4. Configure lifts in `config.lua` to match your desired locations
5. Restart your server

## Configuration

Edit `config.lua` to customize your parking lifts:

```lua
Config.Lifts = {
    [1] = {
        platform = {
            model = 'prop_container_01a',  -- Prop model for platform
            coords = vector3(-160.0, -583.0, 32.42),  -- Platform location
            rotation = vector3(0.0, 0.0, 0.0),  -- Platform rotation
        },
        interaction = {
            coords = vector3(-160.0, -583.0, 32.42),  -- Interaction point
            distance = 2.5,  -- Interaction distance
        },
        movement = {
            speed = 0.05,  -- Movement speed (units per frame)
            downDistance = 10.0,  -- Distance to travel down
            returnDelay = 5000,  -- Delay before returning (ms)
        },
        vehicleZone = {
            coords = vector3(-160.0, -583.0, 32.42),
            radius = 4.0,  -- Vehicle detection radius
        },
    },
}
```

### Configuration Options

- **Config.UseTarget**: Set to `true` to use qb-target, `false` for key press interaction
- **Config.InteractionKey**: Key code for interaction (default: 38 = E key)
- **Config.Debug**: Enable debug console logging

### ⚠️ Important Configuration Notes

**Vehicle Detection Zone**: The `vehicleZone.coords` should match (or be very close to) your `platform.coords`! This is the most common configuration mistake.

For best results, **use the exact same coordinates** for both. The system allows up to **10 units** of difference as a tolerance, but exact matching is recommended to ensure reliable vehicle detection.

- ✅ **Correct**: Both platform and vehicleZone at the same location
  ```lua
  platform = { coords = vector3(100.0, 200.0, 30.0) }
  vehicleZone = { coords = vector3(100.0, 200.0, 30.0) }  -- Same coords
  ```

- ❌ **Wrong**: Different coordinates will cause "No vehicle detected" errors
  ```lua
  platform = { coords = vector3(100.0, 200.0, 30.0) }
  vehicleZone = { coords = vector3(-160.0, -583.0, 32.42) }  -- Default coords, far away!
  ```

The script will display a **red error message** on startup if your vehicleZone is more than 10 units away from the platform.

## Usage

### For Players

1. Park your vehicle on the platform
2. Walk to the interaction point
3. Press E (or use qb-target) to activate the lift
4. The platform will descend with your vehicle
5. Your vehicle will be stored (deleted) when the platform reaches the bottom
6. The platform will automatically return to the surface after a delay

### For Server Owners

1. Use the config to set up multiple lifts at different locations
2. Adjust speed, distance, and delay to match your preferences
3. Choose between qb-target integration or key press interaction
4. Enable debug mode for troubleshooting

## Adding Multiple Lifts

Simply add more entries to the `Config.Lifts` table:

```lua
Config.Lifts = {
    [1] = { -- First lift
        platform = { ... },
        -- ... other settings
    },
    [2] = { -- Second lift
        platform = { ... },
        -- ... other settings
    },
}
```

## How It Works

1. **Initialization**: Platform objects are spawned at configured locations
2. **Vehicle Detection**: System detects vehicles within the platform radius
3. **Activation**: Player interacts with the lift
4. **Descent**: Platform moves down smoothly, taking vehicles with it
5. **Storage**: Vehicles are deleted server-side (simulating storage)
6. **Return**: After a delay, platform returns to original position
7. **Sync**: All movements are synchronized across all clients

## Performance Optimization

- Uses efficient entity pooling for vehicle detection
- Proper cleanup on resource stop
- Optimized movement calculations
- Synchronized network events to prevent desyncs
- Minimal resource usage with thread management

## Troubleshooting

- **Lift not appearing**: Check coordinates in config.lua and ensure the prop model exists
- **No interaction prompt**: Verify qb-target is installed if Config.UseTarget is true
- **"No vehicle detected on platform" error**: 
  - **Most common cause**: Your `vehicleZone.coords` doesn't match your `platform.coords`
  - Check the console for red error messages on startup - they will show the mismatch
  - Solution: Update `vehicleZone.coords` to match your `platform.coords` exactly
  - If coords are correct, try increasing `vehicleZone.radius` (default: 4.0, try 5.0-6.0)
- **Vehicles slingshot into air or don't follow platform underground**:
  - This is caused by collision between vehicle and ground when forced underground
  - Solution: Ensure `Config.DisableVehicleCollisionDuringMovement = true` in config.lua (default)
  - The system attaches vehicles to the platform entity for perfect synchronization
  - Vehicles are detached and collision is restored before deletion
- **Movement too fast/slow**: Adjust movement speed in config

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created by ChilLLix for the QBCore Framework community.

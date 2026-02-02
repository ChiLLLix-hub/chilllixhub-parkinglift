# Installation Verification Guide

## Quick Test Steps

To verify the parking lift script is installed correctly, follow these steps:

### 1. Check Resource Loading

When your server starts, check the console for:
```
[Parking Lift Server] Parking Lift Server initialized
```

### 2. In-Game Verification

1. **Start the resource**: 
   - Ensure `ensure chilllixhub-parkinglift` is in your `server.cfg`
   - Restart your server or use `/restart chilllixhub-parkinglift`

2. **Check platform spawning**:
   - Navigate to the coordinates specified in your `config.lua`
   - Default location: `vector3(-160.0, -583.0, 32.42)`
   - You should see the platform object (default: container)

3. **Test interaction**:
   - If using qb-target: Look at the platform, you should see the interaction icon
   - If using key press: Stand near the platform and press E

4. **Test functionality**:
   - Park a vehicle on the platform
   - Activate the lift
   - Observe: Platform should move down with vehicle
   - Vehicle should disappear when platform reaches bottom
   - Platform should return to original position after delay

### 3. Enable Debug Mode

For troubleshooting, enable debug mode in `config.lua`:
```lua
Config.Debug = true
```

You'll see console messages like:
- `Platform created for lift 1 Entity ID: XXX`
- `Vehicle detected on platform: XXX`
- `Activating lift 1 with X vehicles`
- `Lift 1 completed cycle`

## Common Issues

### Platform Not Appearing
- Check coordinates are correct for your server
- Verify the prop model exists (`prop_container_01a`)
- Ensure QBCore is loaded before this resource

### No Interaction Prompt
- If using qb-target, ensure it's installed and running
- If using key press, check `Config.UseTarget = false`
- Verify you're within interaction distance

### Vehicle Not Moving with Platform
- Check vehicle is within the detection radius
- Increase `vehicleZone.radius` if needed
- Ensure vehicle is actually on the platform

### Platform Stuck or Not Returning
- Check server console for errors
- Verify movement speed isn't too slow/fast
- Check return delay isn't too long

## Performance Check

The script is optimized for performance:
- Single vehicle detection check per lift activation
- Efficient entity pooling
- Proper cleanup on resource stop
- Minimal network events

### Recommended Settings

For best performance:
- `speed = 0.05` (smooth but not too slow)
- `downDistance = 10.0` (reasonable parking depth)
- `returnDelay = 5000` (5 seconds, adjustable)
- `radius = 4.0` (catches most vehicles without being too large)

## Security Notes

The script includes server-side validation to prevent:
- Client-side parameter manipulation
- Unauthorized lift activations
- Vehicle deletion exploits

All critical operations are validated server-side using config values.

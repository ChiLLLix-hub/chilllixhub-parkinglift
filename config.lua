Config = {}

-- Lift Configuration
Config.Lifts = {
    [1] = {
        -- Platform object settings
        platform = {
            model = 'prop_container_01a', -- Default prop model, can be changed
            coords = vector3(-160.0, -583.0, 32.42), -- Initial platform spawn coordinates
            rotation = vector3(0.0, 0.0, 0.0), -- Platform rotation
        },
        
        -- Interaction zone settings (where player can interact)
        interaction = {
            coords = vector3(-160.0, -583.0, 32.42), -- Interaction point
            width = 2.0, -- Interaction zone width
            length = 2.0, -- Interaction zone length
            heading = 0.0,
            minZ = 31.42,
            maxZ = 33.42,
            distance = 2.5, -- Max distance to interact
        },
        
        -- Movement settings
        movement = {
            speed = 0.05, -- Movement speed (units per frame)
            downDistance = 10.0, -- Distance to move down (in units)
            returnDelay = 5000, -- Delay before platform returns (milliseconds)
        },
        
        -- Vehicle detection zone (on platform)
        -- IMPORTANT: These coords MUST match the platform coords above!
        -- The detection zone should be centered on the platform
        vehicleZone = {
            coords = vector3(-160.0, -583.0, 32.42), -- MUST match platform.coords
            radius = 4.0, -- Detection radius for vehicles
        },
    },
    
    -- Add more lifts by adding more entries
    -- [2] = { ... },
}

-- Interaction settings
Config.UseTarget = true -- Set to true if using qb-target, false for DrawText
Config.InteractionKey = 38 -- E key (default)

-- Labels and text
Config.Labels = {
    interact = '[E] Use Parking Lift',
    liftBusy = 'Lift is currently in use',
    noVehicle = 'No vehicle detected on platform',
}

-- Debug mode (set to true for console logging)
Config.Debug = false

-- Technical settings (advanced users)
Config.MovementTimeMultiplier = 10 -- Multiplier for calculating movement duration based on speed
Config.VehiclePlatformOffset = 1.0 -- Vertical offset for vehicles on platform (in units)
Config.DisableVehicleCollisionDuringMovement = true -- Disable collision to prevent slingshot effect when going underground
Config.InitializationDelay = 1000 -- Delay before initializing lifts (milliseconds)

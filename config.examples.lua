-- Example configurations for different scenarios

--[[
    SCENARIO 1: Fast Parking Garage
    - Quick descent and return
    - Small detection radius
    - Short delay
]]
Config.Lifts[1] = {
    platform = {
        model = 'prop_container_01a',
        coords = vector3(-160.0, -583.0, 32.42),
        rotation = vector3(0.0, 0.0, 0.0),
    },
    interaction = {
        coords = vector3(-160.0, -583.0, 32.42),
        width = 2.0,
        length = 2.0,
        heading = 0.0,
        minZ = 31.42,
        maxZ = 33.42,
        distance = 2.5,
    },
    movement = {
        speed = 0.1,  -- Fast speed
        downDistance = 8.0,  -- Short distance
        returnDelay = 3000,  -- 3 seconds
    },
    vehicleZone = {
        coords = vector3(-160.0, -583.0, 32.42),
        radius = 3.5,  -- Tight detection
    },
}

--[[
    SCENARIO 2: Luxury Underground Parking
    - Slow, smooth descent
    - Large detection radius for big vehicles
    - Longer delay for effect
]]
Config.Lifts[2] = {
    platform = {
        model = 'prop_conc_slab_02',  -- Concrete slab
        coords = vector3(-200.0, -600.0, 35.0),
        rotation = vector3(0.0, 0.0, 90.0),
    },
    interaction = {
        coords = vector3(-200.0, -600.0, 35.0),
        width = 3.0,
        length = 3.0,
        heading = 90.0,
        minZ = 34.0,
        maxZ = 36.0,
        distance = 3.0,
    },
    movement = {
        speed = 0.03,  -- Very smooth/slow
        downDistance = 15.0,  -- Deep underground
        returnDelay = 10000,  -- 10 seconds
    },
    vehicleZone = {
        coords = vector3(-200.0, -600.0, 35.0),
        radius = 5.0,  -- Large radius
    },
}

--[[
    SCENARIO 3: Commercial Parking
    - Medium speed
    - Multiple lifts side by side
    - Efficient timing
]]
Config.Lifts[3] = {
    platform = {
        model = 'prop_container_01a',
        coords = vector3(-180.0, -583.0, 32.42),
        rotation = vector3(0.0, 0.0, 0.0),
    },
    interaction = {
        coords = vector3(-180.0, -583.0, 32.42),
        width = 2.0,
        length = 2.0,
        heading = 0.0,
        minZ = 31.42,
        maxZ = 33.42,
        distance = 2.5,
    },
    movement = {
        speed = 0.05,  -- Standard speed
        downDistance = 10.0,  -- Standard depth
        returnDelay = 5000,  -- 5 seconds
    },
    vehicleZone = {
        coords = vector3(-180.0, -583.0, 32.42),
        radius = 4.0,  -- Standard radius
    },
}

--[[
    SCENARIO 4: Motorcycle/Small Vehicle Lift
    - Faster speed for smaller vehicles
    - Smaller platform and detection
]]
Config.Lifts[4] = {
    platform = {
        model = 'prop_crate_11e',  -- Smaller crate
        coords = vector3(-190.0, -583.0, 32.42),
        rotation = vector3(0.0, 0.0, 0.0),
    },
    interaction = {
        coords = vector3(-190.0, -583.0, 32.42),
        width = 1.5,
        length = 1.5,
        heading = 0.0,
        minZ = 31.42,
        maxZ = 33.42,
        distance = 2.0,
    },
    movement = {
        speed = 0.08,  -- Quick for small vehicles
        downDistance = 6.0,  -- Shallow
        returnDelay = 4000,  -- 4 seconds
    },
    vehicleZone = {
        coords = vector3(-190.0, -583.0, 32.42),
        radius = 2.5,  -- Small radius
    },
}

--[[
    AVAILABLE PROP MODELS (some examples):
    
    Containers:
    - prop_container_01a
    - prop_container_01b
    - prop_container_02a
    
    Concrete/Industrial:
    - prop_conc_slab_01
    - prop_conc_slab_02
    - prop_conc_slab_03
    
    Crates:
    - prop_crate_11e
    - prop_crate_11d
    
    Custom: Use any prop model hash or name
]]

--[[
    PROP POSITIONING TIPS:
    
    1. Use tools like CodeWalker or in-game editors to find coordinates
    2. Z coordinate should be at ground level
    3. Rotation affects platform orientation (usually keep at 0,0,0)
    4. Test with different vehicles to ensure proper detection
    5. Adjust radius based on vehicle types (cars vs trucks)
]]

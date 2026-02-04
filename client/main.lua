local QBCore = exports['qb-core']:GetCoreObject()
local lifts = {}
local isLiftActive = {}

-- Configuration validation constants
local MAX_VEHICLE_ZONE_DISTANCE = 10.0 -- Maximum allowed distance between platform and vehicleZone coords

-- Debug print function
local function DebugPrint(...)
    if Config.Debug then
        print('^3[Parking Lift]^7', ...)
    end
end

-- Validate lift configuration
local function ValidateLiftConfig(liftId, liftConfig)
    -- Check if vehicleZone coords match platform coords
    local platformCoords = liftConfig.platform.coords
    local vehicleZoneCoords = liftConfig.vehicleZone.coords
    
    -- Calculate distance between vectors using FiveM's vector magnitude operator
    -- #(vector1 - vector2) calculates the Euclidean distance between two vectors
    local distance = #(platformCoords - vehicleZoneCoords)
    
    -- If coords are more than the allowed distance apart, show warning
    if distance > MAX_VEHICLE_ZONE_DISTANCE then
        print(string.format('^1[Parking Lift ERROR]^7 Lift %d: vehicleZone.coords is %.1f units away from platform.coords!', 
                           liftId, distance))
        print(string.format('^1[Parking Lift ERROR]^7 Platform coords: %.1f, %.1f, %.1f', 
                           platformCoords.x, platformCoords.y, platformCoords.z))
        print(string.format('^1[Parking Lift ERROR]^7 VehicleZone coords: %.1f, %.1f, %.1f', 
                           vehicleZoneCoords.x, vehicleZoneCoords.y, vehicleZoneCoords.z))
        print('^1[Parking Lift ERROR]^7 Vehicle detection will NOT work! Update vehicleZone.coords to match platform.coords')
        return false
    end
    
    return true
end

-- Create platform object
local function CreatePlatform(liftId, liftConfig)
    local model = GetHashKey(liftConfig.platform.model)
    RequestModel(model)
    
    while not HasModelLoaded(model) do
        Wait(100)
    end
    
    local obj = CreateObject(model, liftConfig.platform.coords.x, liftConfig.platform.coords.y, 
                             liftConfig.platform.coords.z, false, true, false)
    
    SetEntityRotation(obj, liftConfig.platform.rotation.x, liftConfig.platform.rotation.y, 
                      liftConfig.platform.rotation.z, 2, true)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    
    DebugPrint('Platform created for lift', liftId, 'Entity ID:', obj)
    
    return obj
end

-- Get vehicles on platform
local function GetVehiclesOnPlatform(liftConfig)
    local vehicles = {}
    local coords = liftConfig.vehicleZone.coords
    local radius = liftConfig.vehicleZone.radius
    
    local allVehicles = GetGamePool('CVehicle')
    
    for _, vehicle in ipairs(allVehicles) do
        if DoesEntityExist(vehicle) then
            local vehCoords = GetEntityCoords(vehicle)
            local distance = #(vector3(coords.x, coords.y, coords.z) - vehCoords)
            
            if distance <= radius then
                table.insert(vehicles, vehicle)
                DebugPrint('Vehicle detected on platform:', vehicle)
            end
        end
    end
    
    return vehicles
end

-- Smooth movement function
local function MovePlatformVertically(platform, targetZ, speed)
    local currentCoords = GetEntityCoords(platform)
    local direction = targetZ > currentCoords.z and 1 or -1
    local isMovingDown = direction == -1
    
    CreateThread(function()
        while true do
            local coords = GetEntityCoords(platform)
            local distanceToTarget = math.abs(coords.z - targetZ)
            
            if distanceToTarget < 0.01 then
                SetEntityCoords(platform, coords.x, coords.y, targetZ, false, false, false, false)
                DebugPrint('Platform reached target Z:', targetZ)
                break
            end
            
            local newZ = coords.z + (speed * direction)
            
            if (direction == 1 and newZ >= targetZ) or (direction == -1 and newZ <= targetZ) then
                newZ = targetZ
            end
            
            SetEntityCoords(platform, coords.x, coords.y, newZ, false, false, false, false)
            
            -- Note: Vehicles are attached to platform and move automatically
            -- No need to manually update vehicle coords
            
            Wait(0)
        end
    end)
end

-- Handle lift activation
local function ActivateLift(liftId, liftConfig)
    if isLiftActive[liftId] then
        QBCore.Functions.Notify(Config.Labels.liftBusy, 'error')
        return
    end
    
    local platform = lifts[liftId]
    if not DoesEntityExist(platform) then
        DebugPrint('Platform does not exist for lift', liftId)
        return
    end
    
    -- Get vehicles on platform
    local vehicles = GetVehiclesOnPlatform(liftConfig)
    
    if #vehicles == 0 then
        QBCore.Functions.Notify(Config.Labels.noVehicle, 'error')
        return
    end
    
    isLiftActive[liftId] = true
    DebugPrint('Activating lift', liftId, 'with', #vehicles, 'vehicles')
    
    -- Attach vehicles to platform for synchronized movement (prevent slingshot effect)
    if Config.DisableVehicleCollisionDuringMovement then
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                -- Disable collision to prevent physics from pushing vehicle back up
                SetEntityCollision(vehicle, false, false)
                
                -- Attach vehicle to platform so it moves automatically with the platform
                -- This ensures perfect synchronization and prevents slingshot effect
                local vehCoords = GetEntityCoords(vehicle)
                local platformCoords = GetEntityCoords(platform)
                local offsetX = vehCoords.x - platformCoords.x
                local offsetY = vehCoords.y - platformCoords.y
                local offsetZ = vehCoords.z - platformCoords.z + Config.VehiclePlatformOffset
                
                AttachEntityToEntity(vehicle, platform, 0, offsetX, offsetY, offsetZ, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                DebugPrint('Attached vehicle to platform:', vehicle)
            end
        end
    end
    
    -- Get current and target positions
    local currentCoords = GetEntityCoords(platform)
    local targetZ = currentCoords.z - liftConfig.movement.downDistance
    
    QBCore.Functions.Notify('Parking lift activated', 'success')
    
    -- Trigger server event to sync movement (server validates and broadcasts to all clients)
    TriggerServerEvent('chilllixhub-parkinglift:server:activateLift', liftId, nil, nil, 
                       liftConfig.movement.speed, liftConfig.movement.returnDelay)
    
    -- Move platform down (attached vehicles will move automatically)
    MovePlatformVertically(platform, targetZ, liftConfig.movement.speed)
    
    -- Wait for platform to reach bottom (calculate based on distance and speed)
    local movementTime = (liftConfig.movement.downDistance / liftConfig.movement.speed) * Config.MovementTimeMultiplier
    Wait(movementTime)
    
    -- Delete vehicles (simulate storage)
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            -- Detach and restore vehicle state before deletion
            if Config.DisableVehicleCollisionDuringMovement then
                -- Detach from platform
                DetachEntity(vehicle, true, true)
                -- Re-enable collision (both parameters true to ensure full collision restoration)
                SetEntityCollision(vehicle, true, true)
            end
            
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('chilllixhub-parkinglift:server:deleteVehicle', vehicleNetId)
            DebugPrint('Requesting deletion for vehicle:', vehicle)
        end
    end
    
    -- Wait before returning
    Wait(liftConfig.movement.returnDelay)
    
    -- Move platform back up
    local originalZ = currentCoords.z
    MovePlatformVertically(platform, originalZ, liftConfig.movement.speed)
    
    -- Wait for platform to return
    Wait(movementTime)
    
    isLiftActive[liftId] = false
    DebugPrint('Lift', liftId, 'completed cycle')
end

-- Setup interaction zones
local function SetupInteractions()
    if Config.UseTarget then
        -- qb-target integration
        for liftId, liftConfig in pairs(Config.Lifts) do
            exports['qb-target']:AddBoxZone('parking_lift_' .. liftId, liftConfig.interaction.coords, 
                liftConfig.interaction.width, liftConfig.interaction.length, {
                    name = 'parking_lift_' .. liftId,
                    heading = liftConfig.interaction.heading,
                    debugPoly = Config.Debug,
                    minZ = liftConfig.interaction.minZ,
                    maxZ = liftConfig.interaction.maxZ,
                }, {
                    options = {
                        {
                            type = 'client',
                            event = 'chilllixhub-parkinglift:client:useLift',
                            icon = 'fas fa-arrow-down',
                            label = Config.Labels.interact,
                            liftId = liftId,
                        },
                    },
                    distance = liftConfig.interaction.distance
                })
        end
    else
        -- DrawText interaction
        CreateThread(function()
            while true do
                local wait = 1000
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                
                for liftId, liftConfig in pairs(Config.Lifts) do
                    local distance = #(playerCoords - liftConfig.interaction.coords)
                    
                    if distance <= liftConfig.interaction.distance then
                        wait = 0
                        QBCore.Functions.DrawText3D(liftConfig.interaction.coords.x, 
                                                    liftConfig.interaction.coords.y, 
                                                    liftConfig.interaction.coords.z, 
                                                    Config.Labels.interact)
                        
                        if IsControlJustPressed(0, Config.InteractionKey) then
                            ActivateLift(liftId, liftConfig)
                        end
                    end
                end
                
                Wait(wait)
            end
        end)
    end
end

-- Event handlers
RegisterNetEvent('chilllixhub-parkinglift:client:useLift', function(data)
    if data and data.liftId then
        local liftConfig = Config.Lifts[data.liftId]
        if liftConfig then
            ActivateLift(data.liftId, liftConfig)
        end
    end
end)

RegisterNetEvent('chilllixhub-parkinglift:client:syncMovement', function(liftId, currentCoords, targetZ, speed)
    local platform = lifts[liftId]
    if DoesEntityExist(platform) then
        MovePlatformVertically(platform, targetZ, speed)
    end
end)

-- Initialize lifts
CreateThread(function()
    -- Wait for QBCore to load
    Wait(Config.InitializationDelay)
    
    DebugPrint('Initializing parking lifts...')
    
    -- Create all lift platforms
    for liftId, liftConfig in pairs(Config.Lifts) do
        -- Validate configuration (will show errors but still create lift for debugging)
        ValidateLiftConfig(liftId, liftConfig)
        
        lifts[liftId] = CreatePlatform(liftId, liftConfig)
        isLiftActive[liftId] = false
        DebugPrint('Lift', liftId, 'initialized')
    end
    
    -- Setup interactions
    SetupInteractions()
    
    DebugPrint('All parking lifts initialized successfully')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for liftId, platform in pairs(lifts) do
        if DoesEntityExist(platform) then
            DeleteObject(platform)
        end
    end
    
    if Config.UseTarget then
        for liftId, _ in pairs(Config.Lifts) do
            exports['qb-target']:RemoveZone('parking_lift_' .. liftId)
        end
    end
end)

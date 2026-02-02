local QBCore = exports['qb-core']:GetCoreObject()

-- Debug print function
local function DebugPrint(...)
    if Config.Debug then
        print('^2[Parking Lift Server]^7', ...)
    end
end

-- Track active lifts
local activeLiftSessions = {}

-- Handle lift activation from client
RegisterNetEvent('chilllixhub-parkinglift:server:activateLift', function(liftId, currentCoords, targetZ, speed, returnDelay)
    local src = source
    
    -- Validate lift ID
    if not liftId or not Config.Lifts[liftId] then
        DebugPrint('Invalid lift ID from player', src)
        return
    end
    
    local liftConfig = Config.Lifts[liftId]
    
    -- Validate parameters against config to prevent client-side manipulation
    if speed ~= liftConfig.movement.speed or returnDelay ~= liftConfig.movement.returnDelay then
        DebugPrint('Parameter mismatch for lift', liftId, 'from player', src)
        return
    end
    
    -- Prevent duplicate activations
    if activeLiftSessions[liftId] then
        DebugPrint('Lift', liftId, 'is already active')
        return
    end
    
    activeLiftSessions[liftId] = true
    DebugPrint('Player', src, 'activated lift', liftId)
    
    -- Use server-side config values for synchronization (not client-provided values)
    local serverTargetZ = liftConfig.platform.coords.z - liftConfig.movement.downDistance
    
    -- Sync movement to all nearby players using server-validated values
    TriggerClientEvent('chilllixhub-parkinglift:client:syncMovement', -1, liftId, liftConfig.platform.coords, 
                       serverTargetZ, liftConfig.movement.speed)
    
    -- Calculate total cycle time (down + delay + up)
    local downDistance = liftConfig.movement.downDistance
    local movementTime = (downDistance / liftConfig.movement.speed) * Config.MovementTimeMultiplier
    local totalCycleTime = (movementTime * 2) + liftConfig.movement.returnDelay
    
    -- Clear active status after cycle completes
    SetTimeout(totalCycleTime, function()
        activeLiftSessions[liftId] = false
        DebugPrint('Lift', liftId, 'cycle completed, now available')
    end)
end)

-- Handle vehicle deletion
RegisterNetEvent('chilllixhub-parkinglift:server:deleteVehicle', function(vehicleNetId)
    local src = source
    
    if not vehicleNetId then
        DebugPrint('Invalid vehicle network ID from player', src)
        return
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        DebugPrint('Deleting vehicle', vehicle, 'requested by player', src)
        DeleteEntity(vehicle)
    else
        DebugPrint('Vehicle', vehicleNetId, 'does not exist or already deleted')
    end
end)

-- Callback to check if lift is active (optional, for future use)
QBCore.Functions.CreateCallback('chilllixhub-parkinglift:server:isLiftActive', function(source, cb, liftId)
    cb(activeLiftSessions[liftId] == true)
end)

-- Initialize
DebugPrint('Parking Lift Server initialized')

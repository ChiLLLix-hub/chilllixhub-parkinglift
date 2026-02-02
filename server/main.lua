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
    
    -- Prevent duplicate activations
    if activeLiftSessions[liftId] then
        DebugPrint('Lift', liftId, 'is already active')
        return
    end
    
    activeLiftSessions[liftId] = true
    DebugPrint('Player', src, 'activated lift', liftId)
    
    -- Sync movement to all nearby players
    TriggerClientEvent('chilllixhub-parkinglift:client:syncMovement', -1, liftId, currentCoords, targetZ, speed)
    
    -- Calculate total cycle time (down + delay + up)
    local downDistance = math.abs(currentCoords.z - targetZ)
    local movementTime = (downDistance / speed) * Config.MovementTimeMultiplier
    local totalCycleTime = (movementTime * 2) + returnDelay
    
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

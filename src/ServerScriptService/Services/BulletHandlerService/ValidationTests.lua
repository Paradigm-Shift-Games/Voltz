--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)

local ValidationTests = {}

export type ValidationDataType = {
	Tool: Tool,
	BulletData: GunDataTypes.BulletData,
	GunConfig: GunDataTypes.GunConfig,
	BinderInstance: any,
    RaycastParams: RaycastParams
}

ValidationTests["HealthCheck"] = function(player: Player, validationData: ValidationDataType): boolean
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
end

local barrelMaxCheckDistance = 16

ValidationTests["BarrelDistanceCheck"] = function(player: Player, validationData: ValidationDataType): boolean
    local bulletData = validationData.BulletData
    local barrelDistance = (bulletData.BarrelPosition - player.Character.RightHand.Position).Magnitude
    return barrelDistance < barrelMaxCheckDistance
end

local marginOfErrorDistanceIncrement = 0.5

ValidationTests["EndPositionCheck"] = function(player: Player, validationData: ValidationDataType): boolean
    local bulletData = validationData.BulletData
    local gunConfig = validationData.GunConfig
    local barrelDistance = (bulletData.BarrelPosition - bulletData.EndPosition).Magnitude
    return barrelDistance < (gunConfig.Range + marginOfErrorDistanceIncrement)
end

local marginOfErrorTimeOffset = 0.05

local function getBulletCount(gunConfig: GunDataTypes.GunConfig, timeOffset: number): number
    if gunConfig.DelayPerShot == 0 then
        return math.round(gunConfig.FireRate * timeOffset)
    else
        local t = 0
        local shots = 0
        while (t < timeOffset) do
            for i = 1, gunConfig.BulletsPerShot do
                shots += 1
                t += ((gunConfig.FireRate * timeOffset)/gunConfig.BulletsPerShot)
                if t > timeOffset then
                    break
                end
            end
        end
        return shots
    end
end

ValidationTests["FireRateCheck"] = function(player: Player, validationData: ValidationDataType): boolean
    local binderInstance = validationData.BinderInstance
    
    local gunConfig = validationData.GunConfig
    local delayPerShot = gunConfig.DelayPerShot
    local bulletsPerShot = gunConfig.BulletsPerShot
    local fireRate = gunConfig.FireRate

    if delayPerShot == 0 and fireRate < 3 then
        local timeOffset = 1/fireRate - marginOfErrorTimeOffset
        local bulletCount = binderInstance.BulletHistory:GetBulletCountFromTimestampOffset(timeOffset)
        if bulletCount >= bulletsPerShot/fireRate then
            return false
        end
    else
        local timeOffset = 0.2
        local bulletCount = binderInstance.BulletHistory:GetBulletCountFromTimestampOffset(timeOffset)
        local requiredBulletCount = getBulletCount(validationData.GunConfig, timeOffset)
        return bulletCount <= requiredBulletCount
    end

    return true
end

ValidationTests["RayCastCheck"] = function(player: Player, validationData: ValidationDataType): boolean
    local raycastParams = validationData.RaycastParams
    local bulletData = validationData.BulletData
    local direction = bulletData.EndPosition - bulletData.BarrelPosition
    if direction.Magnitude < 10 then
        return true
    end
    local unitDirection = direction.Unit
    local rayResult = workspace:Raycast(bulletData.BarrelPosition + unitDirection, direction - 3 * unitDirection, raycastParams)
    if rayResult then
        return false
    end
    return true
end

return ValidationTests
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)
local BulletHistory = require(script.BulletHistory)

type validationDataType = {
    Tool: Tool,
    BulletData: GunDataTypes.BulletData,
    GunConfig: GunDataTypes.GunConfig,
    BinderInstance: any
}

local BulletHandlerService = Knit.CreateService {
    Name = "BulletHandlerService";
    Client = {};
}
BulletHandlerService.DEBUG_MODE = true

local damageMultiplierList = {
    ["Head"] = 2,
    ["UpperTorso"] = 1.1,
    ["LowerTorso"] = 0.9,

    ["RightUpperLeg"] = 0.8,
    ["RightLowerLeg"] = 0.8,
    ["RightFoot"] = 0.8,
    ["LeftUpperLeg"] = 0.8,
    ["LeftLowerLeg"] = 0.8,
    ["LeftFoot"] = 0.8,

    ["RightUpperArm"] = 0.7,
    ["RightLowerArm"] = 0.7,
    ["RightHand"] = 0.7,
    ["LeftUpperArm"] = 0.7,
    ["LeftLowerArm"] = 0.7,
    ["LeftHand"] = 0.7
}

function BulletHandlerService:_log(str: string, ...): nil
    if not self.DEBUG_MODE then
        return
    end
    print("[BulletHandlerService] " .. str:format(...))
end

function BulletHandlerService:GetRaycastBlacklist(): Array<Instance>
	local blacklist = CollectionService:GetTagged("Character")
	return blacklist
end

local validationTests = {}
do
    validationTests["HealthCheck"] = function(player: Player, validationData: validationDataType): boolean
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return false
        end
    end

    local barrelMaxCheckDistance = 16

    validationTests["BarrelDistanceCheck"] = function(player: Player, validationData: validationDataType): boolean
        local bulletData = validationData.BulletData
        local barrelDistance = (bulletData.BarrelPosition - player.Character.RightHand.Position).Magnitude
        return barrelDistance < barrelMaxCheckDistance
    end

    local marginOfErrorDistanceIncrement = 0.5

    validationTests["EndPositionCheck"] = function(player: Player, validationData: validationDataType): boolean
        local bulletData = validationData.BulletData
        local gunConfig = validationData.GunConfig
        local barrelDistance = (bulletData.BarrelPosition - bulletData.EndPosition).Magnitude
        return barrelDistance < (gunConfig.Range+marginOfErrorDistanceIncrement)
    end

    local marginOfErrorTimeOffset = 0.05

    local function getBulletCount(gunConfig: GunDataTypes.GunConfig, timeOffset: number): number
        if gunConfig.DelayPerShot == 0 then
            return math.round(gunConfig.FireRate*timeOffset)
        else
            local t = 0
            local shots = 0
            while (t < timeOffset) do
                for i = 1, gunConfig.BulletsPerShot do
                    shots += 1
                    t += ((gunConfig.FireRate*timeOffset)/gunConfig.BulletsPerShot)
                    if t > timeOffset then
                        break
                    end
                end
            end
            return shots
        end
    end

    validationTests["FireRateCheck"] = function(player: Player, validationData: validationDataType): boolean
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

    validationTests["RayCastCheck"] = function(player: Player, validationData: validationDataType): boolean
        local blacklist = BulletHandlerService:GetRaycastBlacklist()
        local bulletData = validationData.BulletData
        local direction = bulletData.EndPosition-bulletData.BarrelPosition
        if direction.Magnitude < 10 then
            return true
        end
        local unitDirection = direction.Unit
        local rayResult = workspace:Raycast(bulletData.BarrelPosition+unitDirection, direction-unitDirection*3)
        if rayResult then
            return false
        end
        return true
    end
end

function BulletHandlerService.Client:FireBullet(player: Player, bulletDataList: Array<GunDataTypes.BulletData>): Array<boolean>
    local BinderService = Knit.GetService("BinderService")

    local bulletData = bulletDataList[1]
    if not bulletData then
        return false
    end
    
    local tool: Tool? = player.Character:FindFirstChildOfClass("Tool")
    if not tool or tool.Name ~= bulletData.ToolName then
        return false
    end
    local gunConfigName = tool:GetAttribute("ConfigName")
    local gunConfig = require(ReplicatedStorage.Common.Config.Guns[gunConfigName])
    gunConfig.DelayPerShot = gunConfig.DelayPerShot or 0
    gunConfig.BulletsPerShot = gunConfig.BulletsPerShot or 1

    local binder = BinderService:Get(gunConfigName)
    local binderInstance = binder:Get(tool)

    if not binderInstance.BulletHistory then
        binderInstance.BulletHistory = BulletHistory.new()
    end

	local function handleBulletData(bulletData: GunDataTypes.BulletData): boolean
        local validationData: validationDataType = {
            Tool = tool,
            BulletData = bulletData,
            GunConfig = gunConfig,
            BinderInstance = binderInstance
        }

        for checkName, validationTest in validationTests do
            local success, returnData = pcall(validationTest, player, validationData)
            if not success then
                BulletHandlerService:_log("Validation check '%s' failed due to error: %s", checkName, returnData)
                return false
            end

            if returnData == false then
                BulletHandlerService:_log("Validation check '%s' failed.", checkName)
                return false
            end
        end

        binderInstance.BulletHistory:AddBulletPoint(1)

        return true
    end

    local function handleBulletHit(bulletData: GunDataTypes.BulletData): nil
        local hitPart = bulletData.HitPart
        local character = hitPart.Parent
        if character == player.Character then
            return
        end

        local humanoid = character and character:FindFirstChild("Humanoid")
        local damageMultiplier = damageMultiplierList[hitPart.Name]
        if humanoid and damageMultiplier then
            local damageAmount = gunConfig.Damage*damageMultiplier
            humanoid:TakeDamage(damageAmount)
        end
    end

    local passedTable = {}

    for index, bulletData in bulletDataList do
        local passed = handleBulletData(bulletData)
        if passed then
            passedTable[index] = true
            if bulletData.HitPart then
                handleBulletHit(bulletData)
            end
        else
            passedTable[index] = false
        end
    end

    return passedTable
end

local function TempCodeToGiveGunsRemoveLaterOkayThxBye()
    local InsertService = game:GetService("InsertService")
    local toolBase = script.AssaultRifle

    local function playerAdded(player: Player)
        local function giveGun(tagName)
            local tool = toolBase:Clone()
            CollectionService:RemoveTag(tool, "AssaultRifle")
            CollectionService:AddTag(tool, tagName)
            tool.Name = tagName
            tool:SetAttribute("ConfigName", tagName)
            tool.Parent = player.Backpack
        end

        local function characterAdded(character: Model)
            giveGun("AssaultRifle")
            giveGun("Shotgun")
            giveGun("SMG")
        end

        player.CharacterAdded:Connect(characterAdded)
        if player.Character then
            task.spawn(characterAdded, player.Character)
        end
    end

    Players.PlayerAdded:Connect(playerAdded)

    for _, player in Players:GetPlayers() do
        task.spawn(playerAdded, player)
    end
end

function BulletHandlerService:KnitInit()
    
end

function BulletHandlerService:KnitStart()
    TempCodeToGiveGunsRemoveLaterOkayThxBye()
end

return BulletHandlerService
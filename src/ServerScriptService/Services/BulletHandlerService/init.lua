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

function BulletHandlerService:_log(str: string, ...)
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
    local barrelMaxCheckDistance = 16

    validationTests["BarrelDistanceCheck"] = function(player: Player, validationData: validationDataType)
        local bulletData = validationData.BulletData
        local barrelDistance = (bulletData.BarrelPosition - player.Character.RightHand.Position).Magnitude
        return barrelDistance < barrelMaxCheckDistance
    end

    local marginOfErrorDistanceIncrement = 0.5

    validationTests["EndPositionCheck"] = function(player: Player, validationData: validationDataType)
        local bulletData = validationData.BulletData
        local gunConfig = validationData.GunConfig
        local barrelDistance = (bulletData.BarrelPosition - bulletData.EndPosition).Magnitude
        return barrelDistance < (gunConfig.Range+marginOfErrorDistanceIncrement)
    end

    local marginOfErrorTimeOffset = 0.05

    validationTests["FireRateCheck"] = function(player: Player, validationData: validationDataType)
        local binderInstance = validationData.BinderInstance
        
        local gunConfig = validationData.GunConfig
        local delayPerShot = gunConfig.DelayPerShot or 0
        local bulletsPerShot = gunConfig.BulletsPerShot or 1
        local fireRate = gunConfig.FireRate

        if delayPerShot == 0 and fireRate < 3 then
            local timeOffset = 1/fireRate - marginOfErrorTimeOffset
            local bulletCount = binderInstance.BulletHistory:GetBulletCountFromTimestampOffset(timeOffset)
            if bulletCount >= bulletsPerShot/fireRate then
                return false
            end
        end

        return true
    end

    validationTests["RayCastCheck"] = function(player: Player, validationData: validationDataType)
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

function BulletHandlerService.Client:FireBullet(player: Player, bulletDataList: Array<GunDataTypes.BulletData>)
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

    local binder = BinderService:Get(gunConfigName)
    local binderInstance = binder:Get(tool)

    if not binderInstance.BulletHistory then
        binderInstance.BulletHistory = BulletHistory.new()
    end

	local function handleBulletData(bulletData: GunDataTypes.BulletData)
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

    for _, bulletData in bulletDataList do
        local passed = handleBulletData(bulletData)
        if passed then
            print("passed!")
        end
    end

    return 0
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local BinderService 

local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)

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

local validationTests = {}
do
    local barrelMaxCheckDistance = 16

    validationTests["BarrelDistanceCheck"] = function(player: Player, bulletData: GunDataTypes.BulletData, gunConfig: GunDataTypes.GunConfig)
        local barrelDistance = (bulletData.BarrelPosition - player.Character.RightHand.Position).Magnitude
        return barrelDistance < barrelMaxCheckDistance
    end

    local marginOfErrorDistanceIncrement = 0.5

    validationTests["EndPositionCheck"] = function(player: Player, bulletData: GunDataTypes.BulletData, gunConfig: GunDataTypes.GunConfig)
        local barrelDistance = (bulletData.BarrelPosition - bulletData.EndPosition).Magnitude
        return barrelDistance < (gunConfig.Range+marginOfErrorDistanceIncrement)
    end

    validationTests["FireRateCheck"] = function(player: Player, bulletData: GunDataTypes.BulletData, gunConfig: GunDataTypes.GunConfig)

    end
end

function BulletHandlerService.Client:FireBullet(player: Player, bulletDataList: Array<GunDataTypes.BulletData>)
    local function handleBulletData(bulletData: GunDataTypes.BulletData)
        local tool: Tool? = player.Character:FindFirstChildOfClass("Tool")
        if not tool or tool.Name ~= bulletData.ToolName then
            return false
        end
        local gunConfigName = tool:GetAttribute("ConfigName")
        local gunConfig = require(ReplicatedStorage.Common.Config.Guns[gunConfigName])

        for checkName, validationTest in validationTests do
            local success, returnData = pcall(validationTest, player, bulletData, gunConfig)
            if not success then
                BulletHandlerService:_log("Validation check '%s' failed due to error: %s", checkName, returnData)
                return false
            end

            if returnData == false then
                BulletHandlerService:_log("Validation check '%s' failed.", checkName)
                return false
            end
        end
    end

    for _, bulletData in bulletDataList do
        handleBulletData(bulletData)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)
local BulletHistory = require(script.BulletHistory)
local ValidationTests = require(script.ValidationTests)

local BulletHandlerService = Knit.CreateService {
	Name = "BulletHandlerService";
	Client = {
		ShotFired = Knit.CreateSignal();
	};
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
	local gunConfig: GunDataTypes.GunConfig = require(ReplicatedStorage.Common.Config.Guns[gunConfigName])
	gunConfig.DelayPerShot = gunConfig.DelayPerShot or 0
	gunConfig.BulletsPerShot = gunConfig.BulletsPerShot or 1

	local binder = BinderService:Get(gunConfigName)
	local binderInstance = binder:Get(tool)

	if not binderInstance.BulletHistory then
		binderInstance.BulletHistory = BulletHistory.new()
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = BulletHandlerService:GetRaycastBlacklist()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local function handleBulletData(bulletData: GunDataTypes.BulletData): boolean
		local validationData: ValidationTests.ValidationDataType = {
			Tool = tool,
			BulletData = bulletData,
			GunConfig = gunConfig,
			BinderInstance = binderInstance,
			RaycastParams = raycastParams
		}

		for checkName, validationTest in ValidationTests do
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

	-- Returns true when a player is hit
	local function handleBulletHit(bulletData: GunDataTypes.BulletData): boolean
		local hitPart = bulletData.HitPart
		local character = hitPart.Parent
		if character == player.Character then
			return false
		end

		local humanoid = character and character:FindFirstChild("Humanoid")
		local damageMultiplier = damageMultiplierList[hitPart.Name]
		if humanoid and damageMultiplier then
			local damageAmount = gunConfig.Damage * damageMultiplier
			humanoid:TakeDamage(damageAmount)
			return true
		end
		return false
	end

	local passedTable = {}

	for index, bulletData: GunDataTypes.BulletData in bulletDataList do
		local passed = handleBulletData(bulletData)
		if passed then
			local hitPlayer = false
			passedTable[index] = true
			if bulletData.HitPart then
				hitPlayer = handleBulletHit(bulletData)
			end
			self.ShotFired:FireExcept(player, player, (hitPlayer and bulletData.HitPart) or bulletData.EndPosition, gunConfigName, index)
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
			giveGun("HighPowerPhotonLancer")
		end

		player.CharacterAdded:Connect(characterAdded)
		if player.Character then
			task.spawn(characterAdded, player.Character)
		end
	end

	Players.PlayerAdded:Connect(playerAdded)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(playerAdded, player)
	end
end

function BulletHandlerService:KnitInit()
	
end

function BulletHandlerService:KnitStart()
	TempCodeToGiveGunsRemoveLaterOkayThxBye()
end

return BulletHandlerService
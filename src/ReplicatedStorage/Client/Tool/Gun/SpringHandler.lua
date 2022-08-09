local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spring = require(ReplicatedStorage.Packages.Spring)

local SpringHandler = {}
SpringHandler.References = {}
SpringHandler.RecoilConfig = {
	LowerArmMovement = 0.165,
	BackArmMovement = 0.1,
	WiggleSpeed = 20,
	WiggleAmount = 0.015,
	ElbowRotationAmount = 0.618
}

type motorValue = {
	RightShoulder: BasePart,
	RightElbow: BasePart,
	RightShoulderDefaultC0: CFrame,
	RightElbowDefaultC0: CFrame
}

type characterReference = {
	Spring: any?,
	LastImpulse: number,
	UpdaterConnected: boolean,
	Motors: motorValue
}

function SpringHandler:Get(character: Model): characterReference
	if self.References[character] then
		return self.References[character]
	end

	local rightShoulder = character:FindFirstChild("RightShoulder", true)
	local rightElbow = character:FindFirstChild("RightElbow", true)

	if (not rightShoulder or not rightElbow) then
		return
	end

	local spring = Spring.new(0)
	spring.Speed = 15
	local referenceObject: characterReference = {
		Spring = spring,
		LastImpulse = 0,
		UpdaterConnected = false,
		Motors = {
			RightShoulder = rightShoulder,
			RightElbow = rightElbow,

			RightShoulderDefaultC0 = rightShoulder.C0,
			RightElbowDefaultC0 = rightElbow.C0
		}
	}
	self.References[character] = referenceObject

	local connection: RBXScriptConnection
	connection = character:GetPropertyChangedSignal("Parent"):Connect(function()
		if character.Parent then
			return
		end
		connection:Disconnect()
		self.References[character] = nil
	end)

	return referenceObject
end

-- Doesn't support motor6D recoil for the minigun, all the other guns should be covered.
function SpringHandler:Impulse(character: Model, impulseForce: number)
	local springObject = self:Get(character)
	if not springObject then
		return
	end
	springObject.Spring:Impulse(impulseForce)
	springObject.LastImpulse = os.clock()
	local motors = springObject.Motors

	if not springObject.UpdaterConnected then
		springObject.UpdaterConnected = true
		local renderId = "SpringUpdate-" .. springObject.LastImpulse
		RunService:BindToRenderStep(renderId, Enum.RenderPriority.Character.Value-1, function()
			local t = os.clock()

			if not self.References[character] or t > springObject.LastImpulse+7 then
				springObject.UpdaterConnected = false
				RunService:UnbindFromRenderStep(renderId)
				return
			end

			local position = math.min(1, springObject.Spring.Position)
			local defaultC0_Shoulder = motors.RightShoulderDefaultC0
			local defaultC0_Elbow = motors.RightElbowDefaultC0

			local lowerArmMovementDivision = 1 / self.RecoilConfig.LowerArmMovement
			local backArmDivision = 1 / self.RecoilConfig.BackArmMovement
			local wiggleSpeed = self.RecoilConfig.WiggleSpeed
			local wiggleAmount = self.RecoilConfig.WiggleAmount
			local elbowmMovementDivision = 1 / self.RecoilConfig.ElbowRotationAmount
			local downwardRotationDivision = 1 / (self.RecoilConfig.ElbowRotationAmount * 0.7)

			local shoulderPositionOffset = CFrame.new(0, -position / lowerArmMovementDivision, position / backArmDivision)
			local shoulderRotationOffset = CFrame.Angles(-position / downwardRotationDivision, math.sin(t * wiggleSpeed) * position * wiggleAmount, 0)
			motors.RightShoulder.C0 = (defaultC0_Shoulder * shoulderPositionOffset) * shoulderRotationOffset

			local elbowPositionOffset = CFrame.new(0, position / lowerArmMovementDivision, 0)
			local elbowRotationOffset = CFrame.Angles(position / elbowmMovementDivision, 0, 0)
			motors.RightElbow.C0 = (defaultC0_Elbow * elbowPositionOffset) * elbowRotationOffset
		end)
	end
end

return SpringHandler
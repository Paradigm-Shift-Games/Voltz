local TweenService = game:GetService("TweenService")

-- Constants
local tweenTime = 0.1
local tweenScale = 1.2

local BlueprintPopEffect = {}
BlueprintPopEffect.__index = BlueprintPopEffect

function BlueprintPopEffect:_build()
	for _, part in ipairs(self.Instance:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(self._parts, part)
		end
	end
end

function BlueprintPopEffect:_pop()
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)

	for _, part in ipairs(self._parts) do
		TweenService:Create(part, tweenInfo, {Size = part.Size * tweenScale}):Play()
	end

	task.delay(tweenTime, function()
		self.Instance:Destroy()
	end)
end

function BlueprintPopEffect.new(instance)
	local self = setmetatable({}, BlueprintPopEffect)

	self.Instance = instance
	self._parts = {}

	self:_build()
	self:_pop()

	return self
end

function BlueprintPopEffect:Destroy()

end

return BlueprintPopEffect
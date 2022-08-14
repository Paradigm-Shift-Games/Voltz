local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local Character = {}
Character.__index = Character

function Character.new(character: Model)
    local self = setmetatable({}, Character)
    self.Instance = character
    self._trove = Trove.new()

	local function onDescendantAdded(instance: Instance)
		if instance:IsA("BasePart") and instance.Parent ~= character then
			instance.CanQuery = false
		end
	end

    for _, descendant: Instance in ipairs(character:GetDescendants()) do
        task.spawn(onDescendantAdded, descendant)
    end

    self._trove:Connect(character.DescendantAdded, onDescendantAdded)
    
    return self
end

function Character:Destroy()
	self._trove:Clean()
end

return Character
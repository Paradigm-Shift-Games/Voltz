-- Abstract tool class
-- Virtual methods must be implemented via sub-classes

local Players = game:GetService("Players")

local Tool = {}
Tool.__index = Tool
Tool.EquipIcon = "rbxassetid://6104405324"

-- private:

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

function Tool:_bindToolEvents()
	self.Instance.Activated:Connect(function(...)
		self:OnActivated(...)
	end)

	self.Instance.Deactivated:Connect(function(...)
		self:OnDeactivated(...)
	end)

	self.Instance.Equipped:Connect(function(...)
		mouse.Icon = Tool.EquipIcon
		self:OnEquipped(...)
	end)

	self.Instance.Unequipped:Connect(function(...)
		mouse.Icon = ""
		self:OnUnequipped(...)
	end)
end

-- public:

-- Virtuals
function Tool:OnActivated() end
function Tool:OnDeactivated() end
function Tool:OnEquipped() end
function Tool:OnUnequipped() end

function Tool.new(instance: Tool)
	local self = setmetatable({}, Tool)
	self.Instance = instance
	self:_bindToolEvents()
	return self
end

function Tool:Destroy()
	self.Instance:Destroy()
end

return Tool
-- Abstract tool class
-- Virtual methods must be implemented via sub-classes

local Tool = {}
Tool.__index = Tool

-- private:

local function BindToolEvents(self)
	self.Instance.Activated:Connect(function(...)
		self:OnActivated(...)
	end)

	self.Instance.Deactivated:Connect(function(...)
		self:OnDeactivated(...)
	end)

	self.Instance.Equipped:Connect(function(...)
		self:OnEquipped(...)
	end)

	self.Instance.Unequipped:Connect(function(...)
		self:OnUnequipped(...)
	end)
end

-- public:

function Tool:OnActivated()
	-- virtual method
end

function Tool:OnDeactivated()
	-- virtual method
end

function Tool:OnEquipped()
	-- virtual method
end

function Tool:OnUnequipped()
	-- virtual method
end

function Tool.new(instance: Tool)
	local self = setmetatable({}, Tool)
	self.Instance = instance
	BindToolEvents(self)
	return self
end

function Tool:Destroy()

end

return Tool
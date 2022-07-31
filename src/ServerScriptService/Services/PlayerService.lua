local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService {
	Name = "PlayerService";
	Client = {};
}

function PlayerService:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		CollectionService:AddTag(player, "Player")
	end)
end

return PlayerService
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
		player.CharacterAdded:Connect(function(character)
			CollectionService:AddTag(character, "Character")
		end)

		-- FIXME: Roblox doesn't destroy player instance by default
		player.AncestryChanged:Connect(function()
			if not player:IsDescendantOf(Players) then
				player:Destroy()
			end
		end)
	end)
end

return PlayerService
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)
local Gun = require(ReplicatedStorage.Client.Tool.Gun)
local SpringHandler = require(ReplicatedStorage.Client.Tool.Gun.SpringHandler)

local GunReplication = Knit.CreateController {
	Name = "GunReplication";
}

function GunReplication:KnitInit()

end

function GunReplication:KnitStart()
	local BulletHandlerService = Knit.GetService("BulletHandlerService")
    
    BulletHandlerService.ShotFired:Connect(function(player: Player, endPoint: any, gunConfigName: string, bulletIndex: number)
        local gunConfig: GunDataTypes.GunConfig = require(ReplicatedStorage.Common.Config.Guns[gunConfigName])
        local tool: Tool? = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if not tool then
            return
        end
        local bulletSpawn: Attachment? = tool:FindFirstChild("BulletSpawn", true)
        if not bulletSpawn then
            return
        end

        Gun.DrawShot(bulletSpawn, endPoint, gunConfig)
        print("bulletindex:", bulletIndex)

        if bulletIndex == 1 then
            Gun.PlaySound(tool, gunConfig)
		    Gun.EmitFlare(tool)
            SpringHandler:Impulse(player.Character, gunConfig.BulletDecoration.ImpulseForce or 10)
        end
    end)
end

return GunReplication
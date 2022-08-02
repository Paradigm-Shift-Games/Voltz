local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spring = require(ReplicatedStorage.Packages.Spring)

local SpringHandler = {}
SpringHandler.References = {}

function SpringHandler:Get(character: Model)
    if self.References[character] then
        return self.References[character]
    end

    local rightShoulder = character:FindFirstChild("RightShoulder", true)
    local rightElbow = character:FindFirstChild("RightElbow", true)

    if (not rightShoulder or not rightElbow) then
        return
    end

    local defaultC0_ShoulderValue = rightShoulder:FindFirstChild("DefaultC0")
    local defaultC0_ElbowValue = rightElbow:FindFirstChild("DefaultC0")

    if (not defaultC0_ShoulderValue) then
        defaultC0_ShoulderValue = Instance.new("CFrameValue")
        defaultC0_ShoulderValue.Value = rightShoulder.C0
        defaultC0_ShoulderValue.Name = "DefaultC0"
        defaultC0_ShoulderValue.Parent = rightShoulder

        defaultC0_ElbowValue = Instance.new("CFrameValue")
        defaultC0_ElbowValue.Value = rightElbow.C0
        defaultC0_ElbowValue.Name = "DefaultC0"
        defaultC0_ElbowValue.Parent = rightElbow
    end

    local spring = Spring.new(0)
    spring.Speed = 15
    local referenceObject = {
        Spring = spring,
        LastImpulse = 0,
        UpdaterConnected = false,
        Motors = {
            RightShoulder = rightShoulder,
            RightElbow = rightElbow
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
            if not self.References[character] or os.clock() > springObject.LastImpulse+7 then
                springObject.UpdaterConnected = false
                RunService:UnbindFromRenderStep(renderId)
                return
            end

            local position = math.min(1, springObject.Spring.Position)
            local defaultC0_Shoulder = motors.RightShoulder.DefaultC0.Value
            local defaultC0_Elbow = motors.RightElbow.DefaultC0.Value

            motors.RightShoulder.C0 = (defaultC0_Shoulder * CFrame.new(0, -position/6, position/10)) * CFrame.Angles(-position/5, 0, 0) * CFrame.Angles(0, math.sin(os.clock()*10)*position*0.03, 0)
            motors.RightElbow.C0 = (defaultC0_Elbow * CFrame.new(0, position/6, 0)) * CFrame.Angles(position/2, 0, 0)
        end)
    end
end

return SpringHandler
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local CurrentCamera = workspace.CurrentCamera

local Fusion = require(Packages.Fusion)
local Timer = require(Packages.Timer)

local Value = Fusion.Value
local Computed = Fusion.Computed

local viewportSize = Value(CurrentCamera.ViewportSize)
local runTime = Value(os.clock())

game:GetService("RunService").RenderStepped:Connect(function()
	if CurrentCamera.ViewportSize ~= viewportSize:get(false) then
		viewportSize:set(CurrentCamera.ViewportSize)
	end

	runTime:set(os.clock())
end)

local serverTime = Value(workspace:GetServerTimeNow())
Timer.Simple(0.05, function()
	serverTime:set(workspace:GetServerTimeNow())
end)

local screenSize = Computed(function()
	if viewportSize:get().Y > 1000 then
		return "Large"
	elseif viewportSize:get().Y > 500 then
		return "Medium"
	else
		return "Small"
	end
end)

local strokeSize = Computed(function()
	if screenSize:get() == "Large" then
		return 3
	elseif screenSize:get() == "Medium" then
		return 2.5
	else
		return 2
	end
end)

return {
	ServerTime = serverTime,
	RunTime = runTime,
	ScreenSize = screenSize,
	ViewportSize = viewportSize,
	StrokeSize = strokeSize,
	Theme = Value("Dark"),
}

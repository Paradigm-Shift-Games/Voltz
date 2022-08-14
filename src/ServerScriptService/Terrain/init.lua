local Generator = require(script.Generator)
local DebugRender = require(script.DebugRender)

local Terrain = {}

function Terrain.Generate(terrainConfig)
	local terrainResult = Generator.Generate(terrainConfig)

	DebugRender.DrawGrid(terrainResult.Terrain, 12)
end

return Terrain
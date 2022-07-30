local Generator = require(script.Generator)
local DebugRender = require(script.DebugRender)

local Terrain = {}

function Terrain.Generate(terrainConfig)
	local terrainGrid = Generator.Generate(terrainConfig)
	DebugRender.DrawGrid(terrainGrid)
end

return Terrain
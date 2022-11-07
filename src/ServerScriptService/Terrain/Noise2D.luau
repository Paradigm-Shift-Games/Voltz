local Noise2D = {}
Noise2D.__index = Noise2D

local random = Random.new()

function Noise2D.new(seed)
	local self = setmetatable({}, Noise2D)
	self._seed = seed or random:NextInteger(-2^53, 2^53)
	return self
end

function Noise2D:Noise(x, y, scale)
	return math.noise(x / scale, y / scale, self._seed)
end

function Noise2D:UnitNoise(x, y, scale)
	local rawNoise = self:Noise(x, y, scale)
	return (rawNoise + 1) / 2
end

function Noise2D:Range(x, y, scale, range)
	local rawNoise = self:Noise(x, y, scale)
	return math.abs(rawNoise) < range
end

function Noise2D:EdgeRange(x, y, scale, range)
	local unitNoise = self:UnitNoise(x, y, scale)
	return unitNoise < range
end

return Noise2D
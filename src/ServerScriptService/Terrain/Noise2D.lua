local Noise2D = {}
Noise2D.__index = Noise2D

local random = Random.new()

function Noise2D.new(seed)
	local self = setmetatable({}, Noise2D)
	self._seed = seed or random:NextInteger()
	return self
end

function Noise2D:Noise(x, y)
	return math.noise(x, y, self._seed)
end

function Noise2D:UnitNoise(x, y)
	local rawNoise = self:Noise(x, y)
	return (rawNoise + 1) / 2
end

function Noise2D:Range(x, y, range)
	local rawNoise = self:RawNoise(x, y)
	return math.abs(rawNoise) < range
end

return Noise2D
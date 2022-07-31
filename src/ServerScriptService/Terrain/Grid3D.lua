local Grid3D = {}
Grid3D.__index = Grid3D

function Grid3D.new()
	local self = setmetatable({}, Grid3D)
	self._cells = {}
	return self
end

function Grid3D:Set(x, y, z, data)
	if not self._cells[x] then
		self._cells[x] = {}
	end

	if not self._cells[x][y] then
		self._cells[x][y] = {}
	end

	if not self._cells[x][y][z] then
		self._cells[x][y][z] = {}
	end

	self._cells[x][y][z] = data
end

function Grid3D:Get(x, y, z)
	if not self._cells[x] then
		return nil
	end

	if not self._cells[x][y] then
		return nil
	end

	return self._cells[x][y][z]
end

function Grid3D:IterateCells(fn)
	for x, xData in pairs(self._cells) do
		for y, yData in pairs(xData) do
			for z, data in pairs(yData) do
				local position = Vector3.new(x, y, z)
				fn(position, data)
			end
		end
	end
end

function Grid3D:GetCells()
	local cells = {}

	self:IterateCells(function(position, data)
		cells[position] = data
	end)

	return cells
end

return Grid3D

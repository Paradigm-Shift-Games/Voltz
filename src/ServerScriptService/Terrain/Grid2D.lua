local Grid2D = {}
Grid2D.__index = Grid2D

function Grid2D.new()
	local self = setmetatable({}, Grid2D)
	self._cells = {}
	return self
end

function Grid2D:Set(x, y, data)
	if not self._cells[x] then
		self._cells[x] = {}
	end

	if not self._cells[x][y] then
		self._cells[x][y] = {}
	end

	self._cells[x][y] = data
end

function Grid2D:Get(x, y)
	if not self._cells[x] then
		return nil
	end

	if not self._cells[x][y] then
		return nil
	end

	return self._cells[x][y]
end

function Grid2D:IterateCells(fn)
	for x, xData in pairs(self._cells) do
		for y, data in pairs(xData) do
			local position = Vector3.new(x, y, 0)
			fn(position, data)
		end
	end
end

function Grid2D:GetCells()
	local cells = {}

	self:IterateCells(function(position, data)
		cells[position] = data
	end)

	return cells
end

return Grid2D

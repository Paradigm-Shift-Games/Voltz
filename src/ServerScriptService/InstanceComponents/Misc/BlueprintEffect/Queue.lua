local Queue = {}
Queue.__index = Queue

local function copyTab(tab)
	local newTab = {}

	for i, v in pairs(tab) do
		newTab[i] = v
	end

	return newTab
end

function Queue:PushStart(element)
	self[self._start] = element
	self._start -= 1
	self._length += 1
end

function Queue:PushEnd(element)
	self[self._end] = element
	self._end += 1
	self._length += 1
end

function Queue:PopStart()
	if self._length <= 0 then
        return
    end

    self._start += 1
	local popped = self[self._start]
	self[self._start] = nil
	self._length -= 1

	return popped
end

function Queue:PopEnd()
	if self._length <= 0 then return end
	self._end -= 1
	local popped = self[self._end]
	self[self._end] = nil
	self._length -= 1
	return popped
end

function Queue:ToArray()
	if self._length <= 0 then return {} end
	local arr = table.create(self._length, nil)
	table.move(self, self._start + 1, self._end - 1, 1, arr)
	return arr
end

function Queue:First()
	return self[self._start + 1]
end

function Queue:Last()
	return self[self._end - 1]
end

function Queue:Size()
	return self._length
end

function Queue.new(arr)
	local self = setmetatable({}, Queue)

	self._arr = copyTab(arr or {})
	self._length = #self._arr

	self._start = 0
	self._end = self._length + 1

	return self
end

return Queue
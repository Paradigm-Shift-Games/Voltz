local BulletHistory = {}
BulletHistory.__index = BulletHistory

type BulletData = {
	Timestamp: number,
	BulletAmount: number
}

function BulletHistory.new()
	local self = setmetatable({}, BulletHistory)
	self.History = {}
	self.MaxBulletAge = 1.05
	self.DeleteOldRecordsIndex = 20
	self.RecordAddedIndex = 0
	return self
end

function BulletHistory:AddBulletPoint(bulletAmount: number)
	local bulletData: BulletData = {
		Timestamp = os.clock(),
		BulletAmount = bulletAmount
	}
	table.insert(self.History, bulletData)
	self.RecordAddedIndex += 1
	self:Cleanup()
end

function BulletHistory:GetBulletCountFromTimestampOffset(timeOffset: number): number
	local bulletCount = 0
	local timestamp = os.clock() - timeOffset

	for i = #self.History, 1, -1 do
		local bulletData: BulletData = self.History[i]
		if bulletData.Timestamp < timestamp then
			break
		end
		bulletCount += bulletData.BulletAmount
	end

	return bulletCount
end

function BulletHistory:Cleanup()
	if self.RecordAddedIndex % self.DeleteOldRecordsIndex ~= 0 then
		return
	end
	local minAge = os.clock() - self.MaxBulletAge
	local newHistoryArray = {}
	for _, bulletData in self.History do
		if minAge < bulletData.Timestamp then
			table.insert(newHistoryArray, bulletData)
		end
	end
	self.History = newHistoryArray
end

return BulletHistory